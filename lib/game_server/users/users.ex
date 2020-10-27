defmodule GameServer.Users.User do
  @type t() :: %__MODULE__{
                 username: String.t(),
                 user_preferences: map(),
                 game_preferences: map()
               }

  defstruct [:username, :user_preferences, :game_preferences]
end