defmodule GameServer.UserRegistryTest do
  use ExUnit.Case

  alias GameServer.UserRegistry
  alias GameServer.UserRegistry.User

  setup do
    :ets.new(:users, [:set, :protected, :named_table])
    {:ok, user} = UserRegistry.create_user("test-user", "secret-password")
    {:ok, user: user}
  end

  test "create a user" do
    assert {:ok,
            %User{
              username: "test-user-2",
              user_preferences: %{avatar: "user", color: "black"},
              game_preferences: %{}
            }} = UserRegistry.create_user("test-user-2", "secret-password")

    assert {:error, "Username already taken."} =
             UserRegistry.create_user("test-user-2", "secret-password")
  end

  test "authenticate" do
    assert UserRegistry.authenticate("test-user", "secret-password")
  end

  test "name invalid" do
    assert {:error, _} = UserRegistry.create_user("aaa", "secret-password")

    assert {:error, _} = UserRegistry.create_user("aaaaaaaaaaaaaaaaaaaaa", "secret-password")

    assert {:error, _} = UserRegistry.create_user("-test-user", "secret-password")
    assert {:error, _} = UserRegistry.create_user("test-user-", "secret-password")
    assert {:error, _} = UserRegistry.create_user("AAAAAA", "secret-password")
    assert {:error, _} = UserRegistry.create_user("*#*@#*$", "secret-password")
  end

  test "password invalid" do
    assert {:error, _} = UserRegistry.create_user("test-user-3", "aaaaaaa")
  end

  test "get existing user" do
    assert {:ok,
            %User{
              username: "test-user",
              user_preferences: %{avatar: "user", color: "black"},
              game_preferences: %{}
            }} = UserRegistry.get_user("test-user")
  end

  test "get user not found" do
    assert {:error, "User does not exist."} = UserRegistry.get_user("missing-user")
  end
end
