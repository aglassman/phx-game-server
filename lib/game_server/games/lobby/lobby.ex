defmodule GameServer.Games.Lobby do

  @moduledoc """
  A Lobby is a GenServer that facilitates matchmaking for a specific game.  A Lobby consists of an `interest` map
  to track who's interested in a game, and a chat log.
  """

  use GenServer

  require Logger
  alias GameServer.Users.User
  alias GameServer.Users.UserEvents
  alias GameServer.Games.Game

  @topic "game_lobby"

  @chat_bot %User{
    username: "*chatbot*"
  }

  defmodule ChatMessage do
    @type t() :: %__MODULE__{
                   user: User.t(),
                   message: String.t(),
                   timestamp: DateTime.t()
                 }

    defstruct [:user, :message, :timestamp]
  end

  def start_link(game_module) do
    %Game{id: id} = game_info = game_module.info()
    GenServer.start_link(__MODULE__, {game_info}, name: {:global, {:game_lobby, id}})
  end

  def request_initial_state(game_id) do
    GenServer.cast({:global, {:game_lobby, game_id}}, {:request_state, self()})
  end

  def request_initial_state() do
    :global.registered_names()
    |> Enum.filter(&(elem(&1,0) == :game_lobby))
    |> Enum.map(&{:global, &1})
    |> Enum.each(&(GenServer.cast(&1, {:request_state, self()})))
  end

  def subscribe(game_id) do
    Phoenix.PubSub.subscribe(GameServer.PubSub, topic(game_id))
  end

  def express_interest(game_id, username, interested) do
    GenServer.cast({:global, {:game_lobby, game_id}}, {:express_interest, username, interested})
  end

  def broadcast_interest(game_id, interest) do
    broadcast(game_id, {:interest, game_id, interest})
  end

  def interest_count(interest) when is_map(interest) do
    interest_count = interest
    |> Map.values()
    |> Enum.filter(&(&1))
    |> Enum.count()
  end

  defp topic(game_id), do: @topic <> ":" <> game_id

  defp broadcast(game_id, payload) do
    Phoenix.PubSub.broadcast(GameServer.PubSub, topic(game_id), payload)
  end

  defp default_message(%Game{name: name}) do
    %ChatMessage{
      user: @chat_bot,
      message: "Welcome to the #{name} lobby.",
      timestamp: DateTime.utc_now()
    }
  end

  defp user_logged_out(username) do
    %ChatMessage{
      user: @chat_bot,
      message: "#{username} has logged out.",
      timestamp: DateTime.utc_now()
    }
  end

  @impl true
  def init({game}) do
    Logger.info("Opening Lobby: #{game.id}")
    UserEvents.subscribe()
    {:ok, {game, interest = %{}, chat_messages = [default_message(game)]}}
  end

  def handle_cast({:ping, reply_to_pid}, {game, _ , _} = state) do
    Logger.info("Pinging #{game.id}. #{inspect self()} -> #{inspect reply_to_pid}")
    GenServer.cast(reply_to_pid, {:pong, game})
    {:noreply, state}
  end

  def handle_cast({:request_state, reply_to_pid}, {game, interest, chat_messages} = state) do
    Logger.info("Sending Lobby State for game: #{game.id}. #{inspect self()} -> #{inspect reply_to_pid}")
    GenServer.cast(reply_to_pid, {:lobby_state, state})
    {:noreply, state}
  end

  def handle_cast({:express_interest, username, interested}, {game, interest, chat_messages}) do
    Logger.info("User #{username} is interested(#{interested}) in playing #{game.name}")
    interest = Map.put(interest, username, interested)
    broadcast_interest(game.id, interest)
    {:noreply, {game, interest, chat_messages}}
  end

  def handle_info({:logged_out, username}, {game, interest, chat_messages}) do
    {user_interested, interest} = Map.pop(interest, username)
    broadcast_interest(game.id, interest)

    if user_interested do
      {:noreply,  {game, interest, chat_messages ++ [user_logged_out(username)]}}
    else
      {:noreply,  {game, interest, chat_messages}}
    end
  end

  def handle_info(event, state) do
    IO.inspect(event)
    {:noreply, state}
  end

end