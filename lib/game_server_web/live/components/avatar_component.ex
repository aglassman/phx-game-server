defmodule AvatarComponent do
  use Phoenix.LiveComponent

  import GameServerWeb.LiveHelpers, only: [to_bulma_color: 1]

  def mount(socket) do
    {:ok, socket }
  end

  def color(%{color: color}), do: to_bulma_color(color)
  def color(%{user: %{user_preferences: %{color: color}}}), do: to_bulma_color(color)

  def avatar(%{avatar: avatar}), do: avatar
  def avatar(%{user: %{user_preferences: %{avatar: avatar}}}), do: avatar

  def render(assigns) do
    ~L"""
    <span class="<%="icon has-text-#{color(assigns)}"%>" data-tooltip="Tooltip Text">
      <i class="<%="fas fa-2x fa-#{avatar(assigns)}"%>" data-tooltip="Tooltip Text"></i>
    </span>
    """
  end

end