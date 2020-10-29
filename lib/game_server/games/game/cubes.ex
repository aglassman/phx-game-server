defmodule GameServer.Games.Game.Cubes do
  use GenServer

  require Logger

  alias GameServer.Games.{
      Game,
      GameBehaviour
    }

  @behaviour GameBehaviour

  @impl GameBehaviour
  def info(), do: %Game{
    id: "cubes",
    name: "Cubes",
    description: "Create a beautiful tile mosaic live!",
    module: __MODULE__
  }

  @impl GameBehaviour
  def new() do
    game_info = info()
    instance_id = UUID.uuid4()
    {:ok, pid} = start_link(instance_id)
    Logger.info("Started new instance of: #{game_info.id} instance_id: #{instance_id}")
    {:ok, game_info, instance_id}
  end

  defp topic(instance_id) do
    "game:cubes:#{instance_id}"
  end


  defp genserver_name(instance_id), do: {:global, {:game, {:cube, instance_id}}}

  def start_link(instance_id) do
    GenServer.start(__MODULE__, {instance_id}, name: genserver_name(instance_id))
  end

  @impl true
  def init({instance_id}) do
    cube_map = (for n <- 1..400, do: {n, :empty}) |> Map.new()
    {:ok, {instance_id, cube_map}}
  end

  def subscribe(instance_id) do
    Phoenix.PubSub.subscribe(GameServer.PubSub, topic(instance_id))
  end

  defp broadcast_state(instance_id, cube_map) do
    Phoenix.PubSub.broadcast GameServer.PubSub, topic(instance_id), {:cube_map, cube_map}
  end

  def request_initial_state(instance_id) do
    GenServer.cast(genserver_name(instance_id), {:cube_map, self()})
  end

  def handle_call(:request_cube_map, _form, {instance_id, cube_map} = state) do
    {:reply, cube_map, state}
  end

  def toggle(instance_id, index, name, color) do
    GenServer.cast(genserver_name(instance_id), {:toggle, {:square, index, {:user, name, color}}})
  end

  def handle_cast({:toggle, {:square, index, {:user, name, color}}}, {instance_id, cube_map}) do
    IO.inspect("got it")
    updated_cube_map = case Map.get(cube_map, index) do
      {:user, ^name, _} -> Map.put(cube_map, index, :empty)
      _ -> Map.put(cube_map, index, {:user, name, color})
    end

    broadcast_state(instance_id, updated_cube_map)

    {:noreply, {instance_id, updated_cube_map}}
  end

  def handle_info(event, state) do
    IO.inspect(event)
    {:noreply, state}
  end

  def terminate(reason, {instance_id, _}) do
    Phoenix.PubSub.broadcast GameServer.PubSub, topic(instance_id), {:game_terminated, instance_id}
  end


end