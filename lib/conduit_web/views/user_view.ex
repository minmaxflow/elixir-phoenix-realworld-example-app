defmodule ConduitWeb.UserView do
  use ConduitWeb, :view
  alias ConduitWeb.UserView

  def render("index.json", %{users: users}) do
    %{user: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{user: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      email: user.email,
      username: user.username,
      bio: user.bio,
      image: user.image,
      token: user.token
    }
  end
end
