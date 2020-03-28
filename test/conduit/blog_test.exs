defmodule Conduit.BlogTest do
  use Conduit.DataCase

  alias Conduit.Blog

  describe "tags" do
    test "get_or_insert_tags" do
      assert tags = Blog.get_or_insert_tags(["tag1", "tag2", "tag3"])

      assert tag2 = Blog.get_or_insert_tags(["tag1", "tag2", "tag3"])

      assert tags == tag2
    end
  end
end
