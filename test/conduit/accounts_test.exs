defmodule Conduit.AccountsTest do
  use Conduit.DataCase

  alias Conduit.Accounts

  describe "users" do
    alias Conduit.Accounts.User

    @valid_attrs %{
      bio: "some bio",
      email: "some@test.com",
      username: "username",
      password: "password",
      image: nil
    }
    @update_attrs %{
      bio: "some updated bio",
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
               bio: "some bio",
               email: "some@test.com",
               username: "username",
               image: nil
             } = user
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = insert_user(@valid_attrs)
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.bio == "some updated bio"
      assert user.username == "newusername"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = insert_user(@valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
    end
  end
end
