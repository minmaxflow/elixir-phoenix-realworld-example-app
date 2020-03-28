defmodule Conduit.AccountsTest do
  use Conduit.DataCase

  alias Conduit.Accounts
  alias Conduit.Accounts.User

  describe "users" do
    alias Conduit.Accounts.User

    @valid_attrs %{
      email: "some@test.com",
      username: "username",
      password: "password"
    }
    @update_attrs %{
      username: "newusername"
    }
    @invalid_attrs %{
      username: "mm",
      password: "pwd"
    }

    test "get_user!/1 returns the user with given id" do
      user = insert_user()
      assert Accounts.get_user!(user.id).id == user.id
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)

      assert %{
               email: "some@test.com",
               username: "username"
             } = user
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = insert_user(@valid_attrs)
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.username == "newusername"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = insert_user(@valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
    end

    test "authenticate_by_username_password/2 " do
      insert_user(@valid_attrs)

      assert {:ok, %User{} = user} =
               Accounts.authenticate_by_username_password(
                 @valid_attrs.email,
                 @valid_attrs.password
               )

      assert {:error, :not_found} =
               Accounts.authenticate_by_username_password("wrong@test.com", @valid_attrs.password)

      assert {:error, :unauthorized} =
               Accounts.authenticate_by_username_password(@valid_attrs.email, "wrong pass")
    end
  end

  describe "user follow" do
    test "with follow/unfollow/profile together" do
      user1 = insert_user(%{email: "user1@test.com", username: "usr1", password: "user1pass"})
      user2 = insert_user(%{email: "user2@test.com", username: "usr2", password: "user2pass"})

      assert %{following: false} = Accounts.get_profile(nil, user1.username)
      assert %{following: false} = Accounts.get_profile(user1, user2.username)

      assert {:ok, _} = Accounts.follow_user(user1, user2.username)
      assert %{following: true} = Accounts.get_profile(user1, user2.username)
      assert %{following: false} = Accounts.get_profile(nil, user2.username)

      assert {:ok, _} = Accounts.unfollow_user(user1, user2.username)
      assert %{following: false} = Accounts.get_profile(user1, user2.username)
      assert %{following: false} = Accounts.get_profile(nil, user2.username)

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_profile(nil, "not exist")
      end

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.follow_user(nil, "not exist")
      end
    end
  end
end
