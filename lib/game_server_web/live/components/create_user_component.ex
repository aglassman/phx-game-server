defmodule CreateUserComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  import GameServerWeb.LiveHelpers, only: [to_bulma_color: 1]

  import GameServer.Users.UserRegistry,
    only: [
      validate_password: 1,
      validate_username: 1,
      username_available?: 1
    ]

  alias GameServer.Users.UserRegistry

  def mount(socket) do
    IO.inspect(["**** mounting #{__MODULE__} ****"])
    validity = %{
      password: nil,
      username: nil,
      username_available: nil
    }

    {:ok, assign(socket,
      validity: validity,
      username: nil,
      password: nil,
      current_user: nil,
      avatar: "user",
      color: "primary",
      error: nil)}
  end

  def handle_event(
        "validate",
        %{"user" => %{
          "password" => password,
          "username" => username,
          "avatar" => avatar,
          "color" => color,
        }} = form,
        socket
      ) do
    IO.inspect(form)

    validity = %{
      password: validate_password(password),
      username: validate_username(username),
      username_available: username_available?(username)
    }

    {:noreply, assign(socket,
      validity: validity,
      username: username,
      password: password,
      avatar: avatar,
      color: color
    )}
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
        %{"user" => %{
          "password" => password,
          "username" => username,
          "avatar" => avatar,
          "color" => color
        }},
        socket
      ) do
      user_properties = %{avatar: avatar, color: color}

      with {:ok, user} <- UserRegistry.create_user(username, password, user_properties) do
        {:noreply, assign(socket, current_user: user)}
      else
        {:error, error_message} -> {:noreply, assign(socket, error: error_message)}
      end
  end

end
