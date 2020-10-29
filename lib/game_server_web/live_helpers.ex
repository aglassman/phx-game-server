defmodule GameServerWeb.LiveHelpers do
  import Phoenix.LiveView

  alias GameServer.Users.UserRegistry


  require Logger

  def assign_defaults(socket, %{"username" => username} = session) do
    with {:ok, user} <- UserRegistry.get_user(username) do
      Logger.debug("Setting assign current_user from username (#{username})")
      assign(socket, current_user: user)
    else
      {:error, error} ->
        Logger.debug("Error setting assign current_user from username #{username}. error: #{error}")
        assign(socket, current_user: nil)
    end
    |> layout_defaults()
  end

  def assign_defaults(socket, _session) do
    Logger.debug("No username in session.")
    socket
    |> assign(current_user: nil)
    |> layout_defaults()
  end

  defp layout_defaults(socket) do
    socket
    |> assign(navbar_expanded: false)
  end

  def require_login(socket, %{"username" => username } = session) when not is_nil(username) do
    socket
    |> layout_defaults()
  end

  def require_login(socket, session) do
    Logger.debug("Require login, no username.")
    redirect(socket, to: "/login")
    |> layout_defaults()
  end

  def to_bulma_color(user_color) do
    case user_color do
      "black" -> "black"
      "teal" -> "primary"
      "blue" -> "link"
      "green" -> "success"
      "yellow" -> "warning"
      "red" -> "danger"
      _ -> "black"
    end
  end

  defmacro __using__(_) do
    quote do
      def handle_event("toggle_navbar", _params, %{assigns: %{navbar_expanded: val}} = socket) do
        {:noreply, assign(socket, navbar_expanded: !val) }
      end
    end
  end

end
