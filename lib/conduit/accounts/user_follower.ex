defmodule Conduit.Accounts.UserFollower do
  use Conduit.Schema
  import Ecto.Changeset

  alias Conduit.Accounts.User

  @primary_key false
  schema "user_followers" do
    belongs_to :follower, User, primary_key: true
    belongs_to :followee, User, primary_key: true

    timestamps()
  end

  @doc false
  def changeset(user_follower, attrs \\ %{}) do
    user_follower
    |> cast(attrs, [])
    |> validate_required([])
    |> unique_constraint(:follower_id, name: :user_followers_follower_id_followee_id_index)
  end
end
