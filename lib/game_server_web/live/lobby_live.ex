defmodule GameServerWeb.LobbyLive do
  use GameServerWeb, :live_view

  require Logger

  import Phoenix.HTML.Tag

  alias GameServer.Games.Lobby
  alias GameServer.Presence

  @impl true
  def mount(%{"game_id" => game_id} = params, session, socket) do
    IO.inspect(["**** mounting #{__MODULE__} ****", params])

    socket = socket
             |> require_login(session)
             |> assign_defaults(session)
             |> assign(game_id: game_id)
             |> assign(lobby_state: nil)
             |> assign(users_in_lobby: [])

    Lobby.request_initial_state(game_id)

    {:ok, socket}
  end

  defp lobby_subscribe(game, socket) do
    if connected?(socket) do
      Logger.debug("Connected")
      Logger.debug("Subscribed to lobby: #{game.id}")
      {:ok, Presence.subscribe_lobby(game.id)}
      {:ok, Lobby.subscribe(game.id)}
      Presence.track_lobby(game.id, socket.assigns.current_user)
    else
      Logger.debug("Not Connected")
    end
  end

  def handle_cast({:lobby_state, {game, interest, chat_messages}}, socket) do
    Logger.debug("Received Lobby State")

    lobby_subscribe(game, socket)

    lobby_state = %{
                    interest: interest,
                    chat_messages: chat_messages,
                    active_players: %{}
                  } |> Map.merge(Map.from_struct(game))

    {:noreply, assign(socket, lobby_state: lobby_state)}
  end

  def handle_info(%{event: "presence_diff"} = event, %{assigns: %{game_id: game_id}} = socket) do
    users_in_lobby = Presence.list_lobby(game_id)
    |> Enum.map(fn {username, %{metas: [user]}} -> Map.take(user, [:username, :user_preferences]) end)
    |> IO.inspect()
    {:noreply, assign(socket, users_in_lobby: users_in_lobby)}
  end

  def handle_info(event, socket) do
    Logger.debug("#{inspect [__MODULE__, "NoOp", event]}")
    {:noreply, socket}
  end

  def handle_cast(request, socket) do
    Logger.debug("#{[__MODULE__, "NoOp", request]}")
    {:noreply, socket}
  end

  def interested_player_count(lobby_state) do
    Lobby.interest_count(lobby_state.interest)
  end

end