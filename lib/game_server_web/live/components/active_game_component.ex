defmodule ActiveGameComponent do
  use Phoenix.LiveComponent

  import GameServerWeb.Router.Helpers
  import Phoenix.HTML.Tag

  @moduledoc """
  Requires @selected_game of type atom()

  Requires @active_game of format:
  %{
    id: String.t(),
    name: String.t(),
    description: String.t()
  }

  """

  def mount(socket) do
    IO.inspect(["**** mounting #{__MODULE__} ****"])
    {:ok, assign(socket, collapsed: false) }
  end

  def handle_event("toggle_collapsed", _, socket) do
    {:noreply, assign(socket, collapsed: !socket.assigns.collapsed)}
  end

  def handle_event("broadcast_interest", %{"interest" => "true"}, socket) do
    send self(), {:broadcast_interest, socket.assigns.active_game, false}
    {:noreply, socket}
  end

  def handle_event("broadcast_interest", %{"interest" => "false"}, socket) do
    send self(), {:broadcast_interest, socket.assigns.active_game, true}
    {:noreply, socket}
  end

  def selected_class(active_game, selected_game) do
    if active_game.id == selected_game do
      "has-background-primary-light"
    else
      ""
    end
  end

  def im_interested?(active_game, current_user) do
    case active_game.interest[current_user.username] do
      nil -> false
      interested -> interested
    end
  end

  def render(assigns) do
    ~L"""
    <div class="tile is-4 p-1">
            <%= tag(:div, class: ["card ", selected_class(@active_game, @selected_game)]) %>
                <header class="card-header">
                    <p class="card-header-title">
                        <%= @active_game.name %>
                    </p>
                    <a href="#" class="card-header-icon" aria-label="more options"  phx-click="toggle_collapsed" phx-target="<%= @myself %>">
                      <span class="icon">
                        <i class="fas fa-angle-down" aria-hidden="true"></i>
                      </span>
                    </a>
                </header>
                <%= if !@collapsed do %>
                  <div class="card-content">
                      <div class="content">
                          <%= @active_game.description %>
                      </div>
                  </div>
                  <footer class="card-footer">
                      <a href="#" class="card-footer-item" phx-click="broadcast_interest" phx-value-interest="<%= im_interested?(@active_game, @current_user) %>" phx-target="<%= @myself %>">
                        <span class="icon">
                          <%= if im_interested?(@active_game, @current_user)  do %>
                            <i class="fas fa-flag" aria-hidden="true"></i>
                          <% else %>
                            <i class="far fa-flag" aria-hidden="true"></i>
                          <% end %>
                        </span>
                      </a>
                      <a href="<%= lobby_path(@socket, :index, @active_game.id)  %>" class="card-footer-item">Lobby</a>
                      <a href="#" class="card-footer-item">Delete</a>
                  </footer>
                <% end %>
            </div>
        </div>
    """
  end
end