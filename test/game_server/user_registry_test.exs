defmodule GameServer.UserRegistryTest do
  use ExUnit.Case

  alias GameServer.UserRegistry

  setup do
    :ets.new(:users, [:set, :protected, :named_table])
    {:ok, user} = UserRegistry.create_user(:ets, "test-user", "secret-password")
    {:ok, user: user}
  end

  test "create a user" do
    assert {:ok, {"test-user-2", %{avatar: "user", color: "black"}, %{}}} =
             UserRegistry.create_user(:ets, "test-user-2", "secret-password")

    assert {:error, "Unable to create user."} =
             UserRegistry.create_user(:ets, "test-user-2", "secret-password")
  end

  test "authenticate" do
    assert UserRegistry.authenticate(:ets, "test-user", "secret-password")
  end

  test "name invalid" do
    assert {:error, _} = UserRegistry.create_user(:ets, "aaa", "secret-password")

    assert {:error, _} =
             UserRegistry.create_user(:ets, "aaaaaaaaaaaaaaaaaaaaa", "secret-password")

    assert {:error, _} = UserRegistry.create_user(:ets, "-test-user", "secret-password")
    assert {:error, _} = UserRegistry.create_user(:ets, "test-user-", "secret-password")
    assert {:error, _} = UserRegistry.create_user(:ets, "AAAAAA", "secret-password")
    assert {:error, _} = UserRegistry.create_user(:ets, "*#*@#*$", "secret-password")
  end

  test "password invalid" do
    assert {:error, _} = UserRegistry.create_user(:ets, "test-user-3", "aaaaaaa")
  end

  test "get existing user" do
    assert {:ok, {"test-user", %{avatar: "user", color: "black"}, %{}}} = UserRegistry.get_user(:ets, "test-user")
  end

  test "get user not found" do
    assert {:error, "User does not exist."} = UserRegistry.get_user(:ets, "missing-user")
  end
end
