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

    test "get_article_by_slug/1", %{user: user, article: %{slug: slug}} do
      assert %{
               slug: ^slug
             } = Blog.get_article_by_slug!(user, slug)
    end

    test "article list", %{user: author, article: %{slug: slug}} do
      assert [%{slug: ^slug}] = Blog.list_articles(nil, %{})

      user = insert_user()
      %{slug: a1} = insert_article(author, %{tagList: ["tag1", "tag2"]})
      %{slug: a2} = insert_article(user, %{tagList: ["tag2", "tag3"]})
      Blog.favorite_article(user, a1)

      assert [%{slug: ^a2}] = Blog.list_articles(nil, %{tag: "tag3"})
      assert [%{slug: ^a1}] = Blog.list_articles(nil, %{favorited: user.username})
      assert [%{slug: ^a2}] = Blog.list_articles(nil, %{author: user.username})

      articles = Blog.list_articles(nil, %{limit: "2"})
      assert length(articles) == 2

      Accounts.follow_user(user, author.username)
      articles = Blog.list_feed_articles(user, %{})
      assert length(articles) == 2
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

    test "article fav", %{article: %{slug: slug}, user: author} do
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

  describe "comments" do
    alias Conduit.Blog.Comment

    @valid_attrs %{body: "some body"}
    @invalid_attrs %{body: nil}

    setup %{} do
      user = insert_user()
      article = insert_article(user)
      comment = insert_comment(user, article)
      {:ok, user: user, article: article, comment: comment}
    end

    test "list_comments/0 returns all comments", %{
      user: user,
      article: article,
      comment: %{id: id}
    } do
      assert [%{id: ^id}] = Blog.list_article_comments(nil)
      assert [%{id: ^id}] = Blog.list_article_comments(user, %{slug: article.slug})
    end

    test "get_comment!/1 returns the comment with given id", %{comment: %{id: id}} do
      assert %{id: ^id} = Blog.get_user_comment!(nil, id)
    end

    test "create_comment/1 with valid data creates a comment", %{user: user, article: article} do
      assert {:ok, %Comment{} = comment} =
               Blog.create_user_comment(user, Map.put(@valid_attrs, :slug, article.slug))

      assert comment.body == "some body"
    end

    test "create_comment/1 with invalid data returns error changeset", %{
      user: user,
      article: article
    } do
      assert {:error, %Ecto.Changeset{}} =
               Blog.create_user_comment(user, Map.put(@invalid_attrs, :slug, article.slug))
    end

    test "delete_comment/1 deletes the comment", %{comment: comment} do
      assert {:ok, %Comment{}} = Blog.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_user_comment!(nil, comment.id) end
    end
  end
end
