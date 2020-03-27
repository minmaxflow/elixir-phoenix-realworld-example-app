defmodule ConduitWeb.UserControllerTest do
  use ConduitWeb.ConnCase

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

  setup %{conn: conn} do
    {:ok,
     conn:
       conn
       |> put_req_header("accept", "application/json")
       |> put_req_header("content-type", "application/json")}
  end

  describe "register user" do
    test "success", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @valid_attrs)
      assert %{"token" => token} = json_response(conn, 201)["user"]
      assert token
    end

    test "fail", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert %{"email" => _, "password" => _} = json_response(conn, 422)["errors"]
    end
  end

  describe "login user" do
    test "success", %{conn: conn} do
      insert_user(@valid_attrs)
      conn = post(conn, Routes.user_path(conn, :login), user: @valid_attrs)
      assert %{"token" => token} = json_response(conn, 200)["user"]
      assert token
    end

    test "fail", %{conn: conn} do
      insert_user(@valid_attrs)
      conn = post(conn, Routes.user_path(conn, :login), user: @invalid_attrs)
      assert %{"errors" => %{"detail" => "Unauthorized"}} = json_response(conn, 401)
    end
  end

  describe "after user login" do
    setup [:create_user]

    test "get current user success", %{conn: conn, user: user} do
      conn = auth_login(conn)
      conn = get(conn, Routes.user_path(conn, :current))
      assert %{"username" => username, "email" => email} = json_response(conn, 200)["user"]
      assert user.username == username
      assert user.email == email
    end

    test "update user success", %{conn: conn, user: user} do
      conn = auth_login(conn)
      conn = put(conn, Routes.user_path(conn, :update, @update_attrs))
      assert %{"username" => username, "email" => email} = json_response(conn, 200)["user"]
      assert @update_attrs.username == username
      assert user.email == email
    end
  end

  describe "without user login" do
    setup [:create_user]

    test "get current user fail", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :current))
      assert %{"errors" => %{"detail" => "Unauthorized"}} = json_response(conn, 401)
    end

    test "udpate user fail", %{conn: conn} do
      conn = put(conn, Routes.user_path(conn, :update, @update_attrs))
      assert %{"errors" => %{"detail" => "Unauthorized"}} = json_response(conn, 401)
    end
  end

  defp auth_login(conn) do
    conn = post(conn, Routes.user_path(conn, :login), user: @valid_attrs)
    response = json_response(conn, 200)
    %{"user" => %{"token" => token}} = response
    conn |> put_req_header("authorization", "Token " <> token)
  end

  defp create_user(_) do
    user = insert_user(@valid_attrs)
    {:ok, user: user}
  end
end
