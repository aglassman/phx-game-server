defmodule GameServerWeb.Auth do
  import Plug.Conn

  alias GameServer.UserRegistry

  def init(opts), do: opts

  def call(conn, _opts) do
    get_user_and_assign(conn, get_session(conn, :username))
  end

  defp get_user_and_assign(conn, nil), do: conn

  defp get_user_and_assign(conn, username) do
    with {:ok, user} <- UserRegistry.get_user(username) do
      assign(conn, :current_user, user)
    else
      {:error, error} -> conn
    end
  end

  #  def authenticated(conn, _opts) do
  #    if conn.assigns.current_user do
  #      conn
  #    else
  #      conn
  #      |> redirect(to: Routes.login_path(conn, :index))
  #      |> halt()
  #    end
  #  end

  def login(conn, username) do
    conn
    |> put_session(:username, username)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    conn
    |> put_session(:username, nil)
    |> configure_session(renew: true)
  end
end
