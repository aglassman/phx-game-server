defmodule GameServer.Presence do
  use Phoenix.Presence,
    otp_app: :game_server,
    pubsub_server: GameServer.PubSub

  require Logger

  alias GameServer.Users.User


  defp lobby(game_id), do: "lobby-presence:#{game_id}"

  def list_lobby(game_id), do: list(lobby(game_id))

  def subscribe_lobby(game_id) do
    Phoenix.PubSub.subscribe(GameServer.PubSub, lobby(game_id))
  end

  def track_lobby(game_id, nil) do
    Logger.debug("Not tracking lobby-presence for #{game_id} due to null username.")
  end

  def track_lobby(game_id, %User{username: username} = current_user) do
    Logger.debug("Tracking lobby-presence for #{username} in lobby #{game_id}.")
    track(
      self(),
      lobby(game_id),
      username,
      current_user
    )
  end
end