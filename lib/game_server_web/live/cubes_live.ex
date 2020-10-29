defmodule GameServerWeb.CubesLive do
  use GameServerWeb, :live_view

  require Logger

  alias GameServer.Games.Game.Cubes
  alias GameServer.Presence
  alias GameServer.Users.UserRegistry

  @impl true
  def mount(%{"instance_id" => instance_id} = params, session, socket) do
    IO.inspect(["**** mounting #{__MODULE__} ****"])
    cube_map = (for n <- 1..400, do: {n, :empty}) |> Map.new()
    socket = assign_defaults(socket, session)

    {:ok, _} = UUID.info(instance_id)

    game_subscribe(instance_id, socket)

    {:ok, assign(socket,
      instance_id: instance_id,
      cube_map: cube_map,
      selected: 1,
      color: socket.assigns.current_user.user_preferences.color,
      name: socket.assigns.current_user.username,
      users_in_game: [])}
  end

  defp game_subscribe(instance_id, socket) do
    if connected?(socket) do
      Logger.debug("Connected")
      Logger.debug("Subscribed to game_instance: #{instance_id}")
      {:ok, Presence.subscribe_game_instance(instance_id)}
     {:ok, Cubes.subscribe(instance_id)}
      Presence.track_game_instance(instance_id, socket.assigns.current_user)
    else
      Logger.debug("Not Connected")
    end
  end

  def handle_info(%{event: "presence_diff"} = event, %{assigns: %{instance_id: instance_id}} = socket) do
    users_in_game = Presence.list_game_instance(instance_id)
                     |> Enum.map(fn {username, %{metas: [user]}} -> Map.take(user, [:username, :user_preferences]) end)
    {:noreply, assign(socket, users_in_game: users_in_game)}
  end


  def handle_event("toggle", %{"index" => index}, %{assigns: %{name: name, color: color, instance_id: instance_id}} = socket) do
    index = String.to_integer(index)
    Cubes.toggle(instance_id, index, name, color)
    {:noreply, socket}
  end

  def handle_event("keypress", %{"key" => "ArrowRight"}, socket) do
    {:noreply, update(socket, :selected, fn i -> i + 1 end)}
  end

  def handle_event("keypress", %{"key" => "ArrowLeft"}, socket) do
    {:noreply, update(socket, :selected, fn i -> i - 1 end)}
  end

  def handle_event("keypress", %{"key" => "ArrowUp"}, socket) do
    {:noreply, update(socket, :selected, fn i -> i - 20 end)}
  end

  def handle_event("keypress", %{"key" => "ArrowDown"}, socket) do
    {:noreply, update(socket, :selected, fn i -> i + 20 end)}
  end

  def handle_event("keypress", %{"key" => " "},
        %{assigns: %{selected: selected, name: name, color: color, instance_id: instance_id}} = socket) do
    Cubes.toggle(instance_id, selected, name, color)
    {:noreply, socket}
  end

  def handle_event("keypress", %{"code" => key }, socket) do
    {:noreply, socket}
  end

  # This is important!
  def handle_event(event,assigns,socket) do
    IO.inspect([:unhandled, event, assigns])
    {:noreply, socket}
  end

  # PubSub callbacks
  def handle_info(:update, socket) do
    {:noreply, update(socket, :selected, fn previous -> rem(previous + 1, 400) end)}
  end

  def handle_info({:cube_map, value}, socket) do
    {:noreply, assign(socket, :cube_map, value)}
  end

  def handle_info({:block_state, block_map}, socket) do
    {:noreply, assign(socket, :block_map, block_map)}
  end

  def handle_info(:terminated, socket) do
    {:noreply, assign(socket, :terminated, true)}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

end
