defmodule GameServer.Games.Game.Othello do

  alias GameServer.Games.{
      Game,
      GameBehaviour
    }

  @behaviour GameBehaviour

  @impl GameBehaviour
  def info(), do: %Game{
    id: "othello",
    name: "Othello",
    description: "Othello is a game where not all is black and white.",
    module: __MODULE__
  }

end