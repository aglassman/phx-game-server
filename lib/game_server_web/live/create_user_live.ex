defmodule GameServerWeb.CreateUserLive do
  use GameServerWeb, :live_view

  alias GameServer.UserRegistry

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    {:ok, assign(socket, [])}
  end

  def handle_info({:create_user, username, password}, socket) do
    with {:ok, user} <- UserRegistry.create_user(username, password) do
      redirect(socket, to: "/")
      {:noreply, assign(socket, user: user)}
    else
      {:error, error_message} -> {:noreply, assign(socket, error: error_message)}
    end
  end
end
