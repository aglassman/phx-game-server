defmodule GameServer.Users.UserEvents do

  require Logger

  @moduledoc """
  This module hides the details of broadcasting and subscribing to user events.
  """

  @topic "user-events"

  def subscribe() do
    Phoenix.PubSub.subscribe(GameServer.PubSub, @topic)
  end

  defp broadcast(payload) do
    Phoenix.PubSub.broadcast(GameServer.PubSub, @topic, payload)
  end

  def logged_out(username), do: broadcast({:logged_out, username})
  def logged_out(nil), do: Logger.debug("Cannot broadcast :logged_out for nil username.")

  def logged_in(username), do: broadcast({:logged_in, username})
  def logged_in(nil), do: Logger.debug("Cannot broadcast :logged_in for nil username.")

end