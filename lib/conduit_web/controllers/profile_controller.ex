defmodule ConduitWeb.ProfileController do
  use ConduitWeb, :controller

  alias ConduitWeb.Guardian
  alias Conduit.Accounts

  action_fallback ConduitWeb.FallbackController

  def action(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    args = [conn, conn.params, user]
    apply(__MODULE__, action_name(conn), args)
  end

  def follow(conn, %{"username" => followee_username}, current_user) do
    with {:ok, _} <- Accounts.follow_user(current_user, followee_username) do
      profile = Accounts.get_profile(current_user, followee_username)
      render(conn, "show.json", profile: profile)
    end
  end

  def unfollow(conn, %{"username" => followee_username}, current_user) do
    with {:ok, _} <- Accounts.unfollow_user(current_user, followee_username) do
      profile = Accounts.get_profile(current_user, followee_username)
      render(conn, "show.json", profile: profile)
    end
  end

  def profile(conn, %{"username" => followee_username}, current_user) do
    profile = Accounts.get_profile(current_user, followee_username)
    render(conn, "show.json", profile: profile)
  end
end
