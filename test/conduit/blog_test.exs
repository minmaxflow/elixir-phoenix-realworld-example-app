defmodule Conduit.BlogTest do
  use Conduit.DataCase

  alias Conduit.Blog
  alias Conduit.Accounts

  describe "tags" do
    test "get_or_insert_tags" do
      assert tags = Blog.get_or_insert_tags(["tag1", "tag2", "tag3"])

      assert tag2 = Blog.get_or_insert_tags(["tag1", "tag2", "tag3"])

      assert tags == tag2
    end
  end

  describe "articles" do
    alias Conduit.Blog.Article

    @valid_attrs %{
      body: "some body",
      description: "some description",
      title: "some title",
      tagList: ["tag1", "tag2"]
    }
    @update_attrs %{
      body: "some updated body",
      description: "some updated description",
      title: "some updated title",
      tagList: ["tag2", "tag3"]
    }
    @invalid_attrs %{
      title: nil
    }

    setup _ do
      user = insert_user()
      article = insert_article(user)
      {:ok, user: user, article: article}
    end

    test "create_article/1 with valid data creates a article", %{user: user} do
      assert {:ok, %Article{} = article} = Blog.create_article(user, @valid_attrs)
      assert article.body == "some body"
      assert article.description == "some description"
      assert article.title == "some title"
      assert byte_size(article.slug) == 12

      tags = Enum.map(article.tags, fn tag -> tag.name end)
      assert Enum.sort(tags) == Enum.sort(@valid_attrs.tagList)
    end

    test "create_article/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Blog.create_article(user, @invalid_attrs)
    end

    test "update_article/2 with valid data updates the article", %{
      article: %{slug: slug} = article
    } do
      # 判断slug没有变
      assert {:ok, %Article{slug: ^slug} = article} = Blog.update_article(article, @update_attrs)
      assert article.body == "some updated body"
      assert article.description == "some updated description"
      assert article.title == "some updated title"

      tags = Enum.map(article.tags, fn tag -> tag.name end)
      assert Enum.sort(tags) == Enum.sort(@update_attrs.tagList)
    end

    test "update_article/2 with invalid data returns error changeset", %{article: article} do
      assert {:error, %Ecto.Changeset{}} = Blog.update_article(article, @invalid_attrs)
    end

    test "delete_article/1 deletes the article", %{article: article} do
      assert {:ok, %Article{}} = Blog.delete_article(article)
    end

    test "article fav", %{article: %{slug: slug} = article, user: author} do
      user = insert_user()

      # init
      assert %{
               favorited: false,
               favorites_count: 0,
               author: %{
                 following: false
               }
             } = Blog.get_article_by_slug!(user, slug)

      # fav article 
      assert {:ok, _} = Blog.favorite_article(user, slug)

      assert %{
               favorited: true,
               favorites_count: 1,
               author: %{
                 following: false
               }
             } = Blog.get_article_by_slug!(user, slug)

      # follow user 
      assert {:ok, _} = Accounts.follow_user(user, author.username)

      assert %{
               favorited: true,
               favorites_count: 1,
               author: %{
                 following: true
               }
             } = Blog.get_article_by_slug!(user, slug)

      # check from third party 
      other_user = insert_user()

      assert %{
               favorited: false,
               favorites_count: 1,
               author: %{
                 following: false
               }
             } = Blog.get_article_by_slug!(other_user, slug)

      # unfav article 
      assert {:ok, _} = Blog.unfavorite_article(user, slug)

      assert %{
               favorited: false,
               favorites_count: 0,
               author: %{
                 following: false
               }
             } = Blog.get_article_by_slug!(other_user, slug)

      assert %{
               favorited: false,
               favorites_count: 0,
               author: %{
                 following: true
               }
             } = Blog.get_article_by_slug!(user, slug)

      # unfollow user 
      assert {:ok, _} = Accounts.unfollow_user(user, author.username)

      assert %{
               favorited: false,
               favorites_count: 0,
               author: %{
                 following: false
               }
             } = Blog.get_article_by_slug!(user, slug)
    end
  end
end
