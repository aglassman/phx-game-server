defmodule GameServerWeb.MatchMakingLive do
  use GameServerWeb, :live_view

  import Phoenix.HTML.Tag

  alias GameServer.Games.GameRegistry
  alias GameServer.Games.Lobby

  @impl true
  def mount(_params, session, socket) do
    IO.inspect(["**** mounting #{__MODULE__} ****"])

    games_summary = get_initial_summary()

    lobby_subscribe(games_summary, socket)

    socket = socket
    |> assign_defaults(session)
    |> assign(games_summary: games_summary)
    |> assign(selected_game: nil)
    {:ok, socket}
  end

  def get_initial_summary() do
    for {game_id, game_info} <-  GameRegistry.game_map(), into: %{} do
      user_game_info = %{
        active_players: nil,
        interested_players: nil,
        im_interested: false
      } |> Map.merge(game_info |> Map.from_struct())

      {game_id, user_game_info}
    end
  end

  def lobby_subscribe(games_summary, socket) do
    if connected?(socket) do
      IO.inspect("Connected")
      for {game_id, _} <- games_summary do
        IO.inspect("subscribed to #{game_id}")
        {:ok, Lobby.subscribe(game_id)}
      end
    else
      IO.inspect("Not Connected")
    end
  end

  def handle_info({:select_game, selected_game}, socket) do
    {:noreply, assign(socket, selected_game: selected_game)}
  end

  def handle_info({:broadcast_interest, active_game, interest}, %{assigns: %{games_summary: games_summary}} = socket) do
#    IO.inspect(["boradcast_interest", active_game.id, interest])
#    updated_summary = put_in(games_summary,[active_game.id, :im_interested],interest)
    Lobby.broadcast_interested(socket.assigns.current_user, active_game.id, interest)
    {:noreply, assign(socket, games_summary: games_summary)}
  end

  def handle_info({:interest_count, game_id, interest_count} = event, %{assigns: %{games_summary: games_summary}} = socket) do
    IO.inspect([__MODULE__, event])
    updated_summary = put_in(games_summary,[game_id, :interested_players], interest_count)
    {:noreply, assign(socket, games_summary: updated_summary)}
  end

  def handle_info(event, socket) do
    IO.inspect([__MODULE__, "NoOp", event])
    {:noreply,socket}
  end
end
