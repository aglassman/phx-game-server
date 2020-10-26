defmodule ActiveGamesSummaryComponent do
  use Phoenix.LiveComponent

  @moduledoc """
  Requires @games_summary of format"
  %{
    id: String.t(),
    name: String.t(),
    active_players: int(),
    interested_players: int()
  }
  """

  def mount(socket) do
    IO.inspect(["**** mounting #{__MODULE__} ****"])
    {:ok, socket}
  end

  def handle_event("select_game", %{"game-id" => game_id}, socket) do
    send self(), {:select_game, game_id}
    {:noreply, socket}
  end

  def selected_class(game_summary, selected_game) do
    if game_summary.id == selected_game do
      "has-background-primary-light"
    else
      ""
    end
  end

  def render(assigns) do
    ~L"""
    <table class="table">
        <thead>
            <tr>
                <th>Game</th>
                <th>Active Games</th>
                <th>Interested Players</th>
            </tr>
        </thead>
        <tbody>
            <%= for { _, game_summary} <- @games_summary do %>
              <tr
                class="<%= selected_class(game_summary, @selected_game) %>"
                phx-click="select_game"
                phx-value-game-id="<%= game_summary.id %>"
                phx-target="<%= @myself %>">
                  <td><%= game_summary.name %></td>

                  <%= if game_summary.active_players do %>
                    <td><%= game_summary.active_players %></td>
                  <% else %>
                    <td><i class="fas fa-spinner fa-pulse"></i></td>
                  <% end %>

                  <%= if game_summary.interested_players do %>
                    <td><%= game_summary.interested_players %></td>
                  <% else %>
                    <td><i class="fas fa-spinner fa-pulse"></i></td>
                  <% end %>
              </tr>
            <% end %>
        </tbody>
    </table>
    """
  end
end