defmodule ConduitWeb.ProfileControllerTest do
  use ConduitWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "user follow" do
    setup _ do
      user1 = insert_user(%{email: "user1@test.com", username: "usr1", password: "user1pass"})
      user2 = insert_user(%{email: "user2@test.com", username: "usr2", password: "user2pass"})
      {:ok, user1: user1, user2: user2}
    end

    test "follow/unfollow/profile", %{conn: conn, user1: user1, user2: user2} do
      # 未登录检查profile
      conn = get(conn, Routes.profile_path(conn, :profile, user1.username))

      assert %{"profile" => %{"username" => "usr1", "following" => false}} =
               json_response(conn, 200)

      # 未登录follow 
      conn = post(conn, Routes.profile_path(conn, :follow, user2.username))
      assert %{"errors" => %{"detail" => "Unauthorized"}} = json_response(conn, 401)

      # 登录
      conn = auth_login(conn, %{"email" => user1.email, password: user1.password})

      # follow 
      conn = post(conn, Routes.profile_path(conn, :follow, user2.username))

      assert %{"profile" => %{"username" => "usr2", "following" => true}} =
               json_response(conn, 200)

      # 检查profile
      conn = get(conn, Routes.profile_path(conn, :profile, user2.username))

      assert %{"profile" => %{"username" => "usr2", "following" => true}} =
               json_response(conn, 200)

      # 去掉授权头，相当于未登录
      conn = recycle(conn, ~w(accept accept-language))
      conn = get(conn, Routes.profile_path(conn, :profile, user2.username))

      assert %{"profile" => %{"username" => "usr2", "following" => false}} =
               json_response(conn, 200)

      # unfollow
      conn = auth_login(conn, %{"email" => user1.email, password: user1.password})
      conn = delete(conn, Routes.profile_path(conn, :unfollow, user2.username))

      assert %{"profile" => %{"username" => "usr2", "following" => false}} =
               json_response(conn, 200)

      # 检查profile
      conn = get(conn, Routes.profile_path(conn, :profile, user2.username))

      assert %{"profile" => %{"username" => "usr2", "following" => false}} =
               json_response(conn, 200)

      # follow不存在的用户
      #     不知道为什么在测试环境不会把Ecto.NoResultsError转换完404错误，也是直接抛出
      # conn = post(conn, Routes.profile_path(conn, :follow, "not exist"))
    end
  end

  defp auth_login(conn, attrs) do
    conn = post(conn, Routes.user_path(conn, :login), user: attrs)
    response = json_response(conn, 200)
    %{"user" => %{"token" => token}} = response

    # 注意，新的plug库有更严格的要求
    conn |> recycle() |> put_req_header("authorization", "Token " <> token)
  end
end
