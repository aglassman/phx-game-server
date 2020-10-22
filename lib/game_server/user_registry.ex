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

  def username_criteria(),
    do:
      "Username must be 4-20 characters, can contain a-z, 0-9, and dashes. Dashes cannot start or end with a dash."

  def available_user_avatars(), do: @valid_user_avatars

  def available_user_colors(), do: @valid_user_colors

  @doc """
  Create a user to be stored.
  """
  @spec create_user(
          ets :: module(),
          name :: String.t(),
          password :: String.t(),
          user_properties :: map()
        ) :: {:ok, map()} | {:error, String.t()}
  def create_user(
        ets,
        username,
        password,
        user_properties \\ %{avatar: "user", color: "black"}
      ) do
    with {:ok, valid_username} <- validate_username(username),
         {:ok, hashed_password} <- validate_and_hash_password(password),
         {:ok, valid_user_properties} <- validate_user_properties(user_properties),
         true <-
           ets.insert_new(
             :users,
             {valid_username, hashed_password, user_properties, game_preferences = %{}}
           ) do
      {:ok, {valid_username, user_properties, game_preferences}}
    else
      {:error, e} -> {:error, e}
      _ -> {:error, "Unable to create user."}
    end
  end

  @spec get_user(
          ets :: module(),
          username :: String.t()
        ) ::
          {:ok, {username :: String.t(), user_preferences :: map(), game_preferences :: map()}}
  def get_user(ets, username) do
    with [{username, _, user_preferences, game_preferences}] <- ets.lookup(:users, username) do
      {:ok, {username, user_preferences, game_preferences}}
    else
      _ -> {:error, "User does not exist."}
    end
  end

  def authenticate(ets, username, password) do
    with [{username, hashed_password, _, _}] <- ets.lookup(:users, username),
         true <- Hasher.check_password_hash(password, hashed_password) do
      {:ok, username}
    else
      _ -> {:error, "User does not exist, or password was incorrect."}
    end
  end

  defp validate_username(username) do
    if String.match?(username, @valid_username_regex) do
      {:ok, username}
    else
      {
        :error,
        username_criteria()
      }
    end
  end

  defp validate_and_hash_password(password) do
    if String.length(password) >= @min_password_length do
      {:ok, Hasher.salted_password_hash(password)}
    else
      {:error, "Password must be >= 8 characters."}
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
end
