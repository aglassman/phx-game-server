defmodule GameServerWeb.LoginController do
  use GameServerWeb, :controller

  alias GameServer.UserRegistry

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def login(conn, %{"user" => %{"username" => username, "password" => password}}) do
    with {:ok, user} <- UserRegistry.authenticate(username, password) do
      conn
      |> GameServerWeb.Auth.login(user)
      |> redirect(to: "/")
    else
      {:error, error_message} ->
        conn
        |> put_flash(:error, error_message)
        |> render("index.html")
    end
  end

  def logout(conn, _params) do
    conn
    |> GameServerWeb.Auth.logout()
    |> redirect(to: "/")
  end

  def login(conn, _params) do
    render(conn, "index.html")
  end

end