defmodule ModalComponent do
  use Phoenix.LiveComponent

  def mount(socket) do
    IO.inspect(["**** mounting #{__MODULE__} ****"])
    {:ok, assign(socket, is_active: false, closable: false)}
  end

  def handle_event("open", _, socket) do
    {:noreply, assign(socket, is_active: true)}
  end

  def handle_event("close", _, socket) do
    {:noreply, assign(socket, is_active: false)}
  end

  def render(assigns) do
    ~L"""
      <div id="<%= @id %>" class="modal <%= if @is_active, do: "is-active" %>">
        <div class="modal-background"></div>
        <div class="modal-content">
            <%= @inner_content.([]) %>
        </div>
        <%= if @closable do %>
          <button
            class="modal-close is-large"
            aria-label="close"
            phx-click="close"
            phx-target="<%= @myself %>"></button>
        <% end %>
      </div>
    """
  end
end
