defmodule GameServerWeb.UserController do
  use GameServerWeb, :controller

  alias GameServer.Users.UserRegistry

  def create(conn,%{"user" => %{
    "password" => password,
    "username" => username,
    "avatar" => avatar,
    "color" => color
  }}) do
    with {:ok, user} <- UserRegistry.create_user(username, password, %{avatar: avatar, color: color}) do
      conn
      |>  GameServerWeb.Auth.login(user.username)
      |> redirect(to: "/")
    else
      {:error, error_message} ->
        conn
        |> put_flash(:error, error_message)
        |> render("index.html")
    end
  end

end