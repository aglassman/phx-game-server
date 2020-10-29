defmodule GameServer.Games.Game.Cubes do

  alias GameServer.Games.{
      Game,
      GameBehaviour
    }

  @behaviour GameBehaviour

  @impl GameBehaviour
  def info(), do: %Game{
    id: "cubes",
    name: "Cubes",
    description: "Create a beautiful tile mosaic live!"
  }

end