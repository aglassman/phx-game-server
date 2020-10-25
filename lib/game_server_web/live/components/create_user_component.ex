defmodule CreateUserComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  import GameServer.UserRegistry,
    only: [
      validate_password: 1,
      validate_username: 1,
      username_available?: 1
    ]

  alias GameServer.UserRegistry

  def mount(socket) do
    validity = %{
      password: nil,
      username: nil,
      username_available: nil
    }

    {:ok, assign(socket, validity: validity, username: nil, password: nil, current_user: nil, error: nil)}
  end

  def handle_event(
        "validate",
        %{"user" => %{"password" => password, "username" => username}},
        socket
      ) do
    validity = %{
      password: validate_password(password),
      username: validate_username(username),
      username_available: username_available?(username)
    }

    {:noreply, assign(socket, validity: validity, username: username, password: password)}
  end

  def allow_create?(validity) do
    match?(
      %{
        password: {:ok, _},
        username: {:ok, _},
        username_available: true
      },
      validity
    )
  end

  def handle_event(
        "create",
        %{"user" => %{"password" => password, "username" => username}},
        socket
      ) do
      with {:ok, user} <- UserRegistry.create_user(username, password) do
        {:noreply, assign(socket, current_user: user)}
      else
        {:error, error_message} -> {:noreply, assign(socket, error: error_message)}
      end
  end
end
