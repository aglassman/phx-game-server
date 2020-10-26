defmodule GameServerWeb.LiveHelpers do
  import Phoenix.LiveView

  def assign_defaults(%{assigns: %{current_user: user}} = socket, _session) do
    socket
  end

  def assign_defaults(socket, %{"username" => username} = _session) do
    with {:ok, user} <- GameServer.UserRegistry.get_user(username) do
      socket = assign(socket, current_user: user)
    else
      {:error, _} -> assign(socket, current_user: nil)
    end
  end

  def assign_defaults(socket, _session) do
    socket
    |> assign(current_user: nil)
  end
end
