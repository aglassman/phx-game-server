defmodule GameServer.Games do

  defmodule Game do

    @type t() :: %__MODULE__{
                   id: String.t(),
                   name: String.t(),
                   description: String.t(),
                   module: module()
                 }

    defstruct [:id, :name, :description, :module]

  end

  defmodule GameBehaviour do

    @callback info() :: Game.t()
    @callback new() :: {:ok, Game.t(), binary()}

  end

  defmodule GameRegistry do

    @games Application.fetch_env!(:game_server, :games)

    def game_map(), do: @games
      |> Enum.map(&(&1.info()))
      |> Enum.map(&({&1.id, &1}))
      |> Map.new()

    def init_lobbies() do
      for game <- @games, into: [] do
        %{
            id: game,
            start: {GameServer.Games.Lobby, :start_link, [game]}
        }
      end
    end

  end

end