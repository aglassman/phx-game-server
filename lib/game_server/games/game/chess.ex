defmodule GameServer.Games.Game.Chess do

  alias GameServer.Games.{
      Game,
      GameBehaviour
    }

  @behaviour GameBehaviour

  @impl GameBehaviour
  def info(), do: %Game{
    id: "chess",
    name: "Chess",
    description: "A two player board game of strategic skill.",
    module: __MODULE__
  }

end