defmodule GameServer.Games.Lobby do
  use GenServer

  require Logger
  alias GameServer.UserRegistry.User
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

  def start(%Game{id: id} = game) do
    {:ok, GenServer.start(__MODULE__, {game}, name: {:global, {:game_lobby, id}})}
    Phoenix.PubSub.broadcast GameServer.PubSub, @topic, {:lobby_open, game}
  end

  def subscribe(game_id) do
    Phoenix.PubSub.subscribe(GameServer.PubSub, topic(game_id))
  end

  def broadcast_interested(%User{} = user, game_id, interested) when is_boolean(interested) do
    broadcast(game_id, {:interest, user, interested})
  end

  def broadcast_interest_count(game_id, interest) do
    broadcast(game_id, {:interest_count, game_id, interest_count(interest)})
  end

  def interest_count(interest) do
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
      timestamp: DateTime.now!("Etc/UTC")
    }
  end

  @impl true
  def init({game}) do
    Logger.info("Opening Lobby: #{game.id}")
    {:ok, Phoenix.PubSub.subscribe(GameServer.PubSub, topic(game.id))}
    {:ok, {game, interest = %{}, chat_messages = [default_message(game)]}}
  end

  def handle_call(:lobby_stats, _form, {game, interest, chat_messages} = state) do
    {
      :reply,
      %{
        interest_count: interest_count(interest),
        active_games: 0
      },
      state}
  end

  def handle_info({:interest, %User{username: username}, interested}, {game, interest, chat_messages}) do
    Logger.info("User #{username} is interested(#{interested}) in playing #{game.name}")
    interest = Map.put(interest, username, interested) |> IO.inspect()
    broadcast_interest_count(game.id, interest)
    {:noreply, {game, interest, chat_messages}}
  end

  def handle_info(event, state) do
    IO.inspect(event)
    {:noreply, state}
  end

end