defmodule GameServer.UserRegistry do
  @valid_username_regex ~r/^(?!\-)[a-z0-9\-]{4,20}(?<!\-)$/

  @min_password_length 8

  @valid_user_avatars [
    "user",
    "user-secret",
    "user-tie",
    "user-md",
    "user-ninja",
    "smile",
    "user-injured",
    "user-graduate",
    "user-astronaut",
    "snowboarding",
    "biking",
    "hiking",
    "suse",
    "taxi",
    "poo",
    "dragon",
    "peace"
  ]

  @valid_user_colors [
    "black",
    "teal",
    "blue",
    "green",
    "yellow",
    "red"
  ]

  defmodule User do
    @type t() :: %__MODULE__{
            username: String.t(),
            user_preferences: map(),
            game_preferences: map()
          }

    defstruct [:username, :user_preferences, :game_preferences]
  end

  def username_criteria(),
    do:
      "Username must be 4-20 characters, can contain a-z, 0-9, and dashes. Dashes cannot start or end with a dash."

  def available_user_avatars(), do: @valid_user_avatars

  def available_user_colors(), do: @valid_user_colors

  @doc """
  Create a user to be stored.
  """
  @spec create_user(
          name :: String.t(),
          password :: String.t(),
          user_properties :: map()
        ) :: {:ok, map()} | {:error, String.t()}
  def create_user(
        username,
        password,
        user_properties \\ %{avatar: "user", color: "black"}
      ) do
    with {:ok, valid_username} <- validate_username(username),
         {:ok, hashed_password} <- validate_and_hash_password(password),
         {:ok, valid_user_properties} <- validate_user_properties(user_properties),
         true <-
           :ets.insert_new(
             :users,
             {valid_username, hashed_password, user_properties, game_preferences = %{}}
           ) do
      {:ok, {valid_username, nil, user_properties, %{}} |> to_user()}
    else
      false -> {:error, "Username already taken."}
      {:error, e} -> {:error, e}
      _ -> {:error, "Unable to create user."}
    end
  end

  @spec username_available?(username :: String.t()) :: boolean()
  def username_available?(username)
      when is_binary(username) and
             not is_nil(username) do
    with {:ok, username} <- validate_username(username) do
      case get_user(username) do
        {:ok, _} -> false
        _ -> true
      end
    else
      {:error, _} -> false
    end
  end

  def username_available?(_), do: false

  @spec get_user(username :: String.t()) ::
          {:ok, {username :: String.t(), user_preferences :: map(), game_preferences :: map()}}
  def get_user(username) do
    with [entry] <- :ets.lookup(:users, username) do
      {:ok, to_user(entry)}
    else
      _ -> {:error, "User does not exist."}
    end
  end

  def authenticate(username, password) do
    with [{username, hashed_password, _, _}] <- :ets.lookup(:users, username),
         true <- Hasher.check_password_hash(password, hashed_password) do
      {:ok, username}
    else
      _ -> {:error, "User does not exist, or password was incorrect."}
    end
  end

  def validate_username(nil), do: validate_username("")

  def validate_username(username) do
    if String.match?(username, @valid_username_regex) do
      {:ok, username}
    else
      {
        :error,
        username_criteria()
      }
    end
  end

  def validate_password(nil), do: validate_password("")

  def validate_password(password) do
    if String.length(password) >= @min_password_length do
      {:ok, password}
    else
      {:error, "Password must be >= 8 characters."}
    end
  end

  defp validate_and_hash_password(password) do
    with {:ok, _} <- validate_password(password) do
      {:ok, Hasher.salted_password_hash(password)}
    end
  end

  defp validate_user_properties(%{avatar: avatar, color: color}) do
    with {:ok, avatar} <- validate_user_avatar(avatar),
         {:ok, color} <- validate_user_color(color) do
      {:ok, %{avatar: avatar, color: color}}
    end
  end

  defp validate_user_avatar(avatar) do
    if Enum.member?(@valid_user_avatars, avatar) do
      {:ok, avatar}
    else
      {:error, "#{avatar} is not a valid user avatar"}
    end
  end

  defp validate_user_color(color) do
    if Enum.member?(@valid_user_colors, color) do
      {:ok, color}
    else
      {:error, "#{color} is not a valid user color"}
    end
  end

  defp to_user({username, _password_hash, user_preferences, game_preferences} = _ets_entry) do
    %User{
      username: username,
      user_preferences: user_preferences,
      game_preferences: game_preferences
    }
  end
end
