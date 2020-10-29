defmodule GameServer.Games.Game.Checkers do

  alias GameServer.Games.{
      Game,
      GameBehaviour
    }

  @behaviour GameBehaviour

  @impl GameBehaviour
  def info(), do: %Game{
    id: "checkers",
    name: "Checkers",
    description: "A two player strategy game where you must capture opponent pieces.",
    module: __MODULE__
  }

end