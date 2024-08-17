defmodule PolyPost.DepotTest do
  use ExUnit.Case, async: false

  alias PolyPost.Depot

  @table :test_articles

  setup do
    start_supervised({Depot, @table})

    {:ok,
     article: %TestArticle{
       key: "my_article.md",
       title: "My Article",
       author: "Me",
       body: "This is my article"
     }}
  end

  describe ".clear/1, .get_all/1 and .insert/3" do
    test "clears the table of all values", %{article: article} do
      Depot.clear(@table)
      assert 0 = Depot.get_all(@table) |> length()

      Depot.insert(@table, article.key, article)
      assert 1 = Depot.get_all(@table) |> length()
    end
  end

  describe ".find/2" do
    test "returns nothing for non-existing key in the table" do
      refute Depot.find(@table, "gobble")
    end

    test "returns a specific object in the table", %{article: article} do
      Depot.insert(@table, article.key, article)
      assert %TestArticle{} = Depot.find(@table, article.key)
    end
  end
end
