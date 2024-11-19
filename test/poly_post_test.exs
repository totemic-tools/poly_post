defmodule PolyPostTest do
  use ExUnit.Case, async: false

  alias PolyPost.Depot

  @resource :test_articles
  @non_existing_resource :test_flights

  @articles_path "test/fixtures/test_articles/*.md"

  @resources [
    front_matter: [decoder: {Jason, :decode, keys: :atoms}],
    content: [
      test_articles: [
        module: TestArticle,
        path: File.cwd!() |> Path.join(@articles_path)
      ]
    ]
  ]

  setup do
    start_supervised({Depot, @resource})

    Application.put_env(:poly_post, :resources, @resources)
  end

  describe ".build_and_store!/1" do
    test "it builds and stores an existing resource" do
      assert :ok = PolyPost.build_and_store!(@resource)
      assert 2 = Depot.get_all(@resource) |> length()
    end

    test "it does not build or store a non-existing resource" do
      assert {:error, :not_found} = PolyPost.build_and_store!(@non_existing_resource)
    end
  end

  describe ".build_and_store_all!/0" do
    test "it builds and stores all existing resources" do
      assert :ok = PolyPost.build_and_store_all!()
      assert 2 = Depot.get_all(@resource) |> length()
    end
  end

  describe ".clear/1" do
    setup do
      PolyPost.build_and_store_all!()
    end

    test "it clears the content from a specific resouce" do
      assert 2 = Depot.get_all(@resource) |> length()
      assert :ok = PolyPost.clear(@resource)
      assert 0 = Depot.get_all(@resource) |> length()
    end

    test "it does not clear content from a non-existing resouce" do
      assert {:error, :not_found} = PolyPost.clear(@non_existing_resource)
    end
  end

  describe ".clear_all/0" do
    setup do
      PolyPost.build_and_store_all!()
    end

    test "it clears all existing resources" do
      assert 2 = Depot.get_all(@resource) |> length()
      assert :ok = PolyPost.clear_all()
      assert 0 = Depot.get_all(@resource) |> length()
    end
  end
end
