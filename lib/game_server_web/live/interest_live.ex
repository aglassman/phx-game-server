defmodule GameServerWeb.InterestLive do
  use GameServerWeb, :live_view

  require Logger

  import Phoenix.HTML.Tag

  alias GameServer.Games.Lobby

  @impl true
  def mount(_params, session, socket) do
    IO.inspect(["**** mounting #{__MODULE__} ****"])

    Lobby.request_initial_state()

    socket = socket
    |> assign_defaults(session)
    |> assign(games_summary: %{})
    |> assign(selected_game: nil)
    {:ok, socket}
  end

  defp lobby_subscribe(game, socket) do
    if connected?(socket) do
      Logger.debug("Connected")
      Logger.debug("Subscribed to #{game.id}")
      {:ok, Lobby.subscribe(game.id)}
    else
      Logger.debug("Not Connected")
    end
  end

  def handle_cast({:lobby_state, {game, interest, chat_messages}}, %{assigns: %{games_summary: games_summary}} = socket) do
    Logger.debug("Recieved Lobby State")

    lobby_subscribe(game, socket)

    lobby_state = %{
      interest: interest,
      chat_messages: chat_messages,
      active_players: %{}
    } |> Map.merge(Map.from_struct(game))

    updated_summary = Map.put(games_summary, game.id, lobby_state)
    {:noreply, assign(socket, games_summary: updated_summary)}
  end

  def handle_cast(request, socket) do
    # IO.inspect([__MODULE__, "NoOp", request])
    {:noreply, socket}
  end

  def handle_info({:select_game, selected_game}, socket) do
    {:noreply, assign(socket, selected_game: selected_game)}
  end

  def handle_info({:broadcast_interest, active_game, interest}, %{assigns: %{games_summary: games_summary}} = socket) do
    Lobby.express_interest(active_game.id, socket.assigns.current_user.username, interest)
    {:noreply, assign(socket, games_summary: games_summary)}
  end

  def handle_info({:interest, game_id, interest} = event, %{assigns: %{games_summary: games_summary}} = socket) do
    # IO.inspect([__MODULE__, event])
    updated_summary = put_in(games_summary,[game_id, :interest], interest)
    {:noreply, assign(socket, games_summary: updated_summary)}
  end

  def handle_info(event, socket) do
    # IO.inspect([__MODULE__, "NoOp", event])
    {:noreply,socket}
  end
end
