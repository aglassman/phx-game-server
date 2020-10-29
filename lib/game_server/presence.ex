defmodule GameServer.Presence do
  use Phoenix.Presence,
    otp_app: :game_server,
    pubsub_server: GameServer.PubSub

  require Logger

  alias GameServer.Users.User


  defp lobby(game_id), do: "lobby-presence:#{game_id}"

  defp game_instance(game_instance), do: "game-instance:#{game_instance}"

  def list_lobby(game_id), do: list(lobby(game_id))

  def list_game_instance(game_id), do: list(game_instance(game_id))

  def subscribe_lobby(game_id) do
    Phoenix.PubSub.subscribe(GameServer.PubSub, lobby(game_id))
  end

  def subscribe_game_instance(game_instance) do
    Phoenix.PubSub.subscribe(GameServer.PubSub, game_instance(game_instance))
  end

  def track_lobby(game_id, nil) do
    Logger.debug("Not tracking lobby-presence for #{game_id} due to null username.")
  end

  def track_game_instance(game_instance, nil) do
    Logger.debug("Not tracking game-instance for #{game_instance} due to null username.")
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

  def track_game_instance(game_instance, %User{username: username} = current_user) do
    Logger.debug("Tracking game-instance for #{username} in lobby #{game_instance}.")
    track(
      self(),
      game_instance(game_instance),
      username,
      current_user
    )
  end
end