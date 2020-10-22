defmodule CreateUserComponent do
  use Phoenix.LiveComponent

  def mount(socket) do
    {:ok, assign(socket, %{})}
  end

  def render(assigns) do
    ~L"""
    <div class="field">
      <label class="label">Name</label>
      <div class="control">
        <input class="input" type="text" placeholder="e.g Alex Smith">
      </div>
    </div>
    """
  end
end
