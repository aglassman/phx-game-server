defmodule GameServerWeb.LiveHelpers do
  import Phoenix.LiveView

  def assign_defaults(_, %{assigns: %{current_user: user}} = socket) do
    socket
  end

  def assign_defaults(%{"username" => username}, socket) do
    with {:ok, user} <- GameServer.UserRegistry.get_user(username) do
      socket = assign(socket, current_user: user)
    else
      {:error, _} -> redirect(socket, to: "/login")
    end
  end

  def assign_defaults(%{}, socket) do
    redirect(socket, to: "/login")
  end
end
