defmodule GameServerWeb.CreateUserLive do
  use GameServerWeb, :live_view

  alias GameServer.Users.UserRegistry

  @impl true
  def mount(_params, session, socket) do
    IO.inspect(["**** mounting #{__MODULE__} ****"])
    socket = assign_defaults(socket, session)
    {:ok, assign(socket, [])}
  end

#  def handle_info({:create_user, username, password, user_properties}, socket) do
#    with {:ok, user} <- UserRegistry.create_user(username, password, user_properties) do
#      socket = socket
#      |> assign(current_user: user)
#      |> redirect(to: "/")
#      {:noreply, socket}
#    else
#      {:error, error_message} -> {:noreply, assign(socket, error: error_message)}
#    end
#  end
end
