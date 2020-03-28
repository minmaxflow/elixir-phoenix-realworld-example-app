defmodule ConduitWeb.TagControllerTest do
  use ConduitWeb.ConnCase

  alias Conduit.Blog

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all tags", %{conn: conn} do
      conn = get(conn, Routes.tag_path(conn, :index))
      assert json_response(conn, 200)["tags"] == []

      Blog.get_or_insert_tags(["tag1"])
      conn = get(conn, Routes.tag_path(conn, :index))
      json_response(conn, 200)
      assert json_response(conn, 200)["tags"] == ["tag1"]
    end
  end
end
