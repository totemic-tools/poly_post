defmodule PolyPost.BuilderTest do
  use ExUnit.Case, async: false
  use Mneme

  alias PolyPost.Builder

  @bad_path "test/fixtures/test_bad/*.md"
  @articles_path "test/fixtures/test_articles/*.md"
  @stories_path "test/fixtures/test_stories/*.md"
  @guides_path "test/fixtures/test_guides/*.md"

  @article_resource :test_articles
  @bad_resource :test_bad

  @resources [
    front_matter: [decoder: {Jason, :decode, keys: :atoms}],
    content: [
      test_articles: [
        module: TestArticle,
        path: File.cwd!() |> Path.join(@articles_path)
      ],
      test_stories: [
        module: TestStory,
        path: File.cwd!() |> Path.join(@stories_path),
        front_matter: [decoder: {YamlElixir, :read_from_string, atoms: true}]
      ],
      test_guides: [
        module: TestGuide,
        path: File.cwd!() |> Path.join(@guides_path),
        front_matter: [decoder: {Toml, :decode, keys: :atoms}]
      ]
    ]
  ]

  @bad_resources [
    front_matter: [decoder: {YamlElixir, :read_from_string, []}],
    content: [
      test_bad: [
        module: TestBad,
        path: File.cwd!() |> Path.join(@bad_path)
      ]
    ]
  ]

  setup_all do
    Application.put_env(:poly_post, :resources, @resources)
  end

  describe ".build!/1" do
    test "it fails to build a specific resource because of bad metadata" do
      Application.put_env(:poly_post, :resources, @bad_resources)

      assert_raise PolyPost.ParsingMetadataError, fn ->
        Builder.build!(@bad_resource)
      end

      Application.put_env(:poly_post, :resources, @resources)
    end

    test "it builds a specific resource" do
      auto_assert [
                    %TestArticle{
                      author: "Me",
                      body:
                        "<h2>\nMy Article 2</h2>\n<p>\nThis is my second article</p>\n<pre><code class=\"elixir\">Enum.map([1, 2, 3], fn x -> x + 1 end)</code></pre>\n",
                      key: "my_article2.md",
                      title: "My Article #2"
                    },
                    %TestArticle{
                      author: "Me",
                      body: "<h2>\nMy Article 1</h2>\n<p>\nThis is my first article</p>\n",
                      key: "my_article1.md",
                      title: "My Article #1"
                    }
                  ] <- Builder.build!(@article_resource)
    end
  end

  describe ".build_all!/0" do
    test "it builds all the resources" do
      auto_assert [
                    test_articles: [
                      %TestArticle{
                        author: "Me",
                        body:
                          "<h2>\nMy Article 2</h2>\n<p>\nThis is my second article</p>\n<pre><code class=\"elixir\">Enum.map([1, 2, 3], fn x -> x + 1 end)</code></pre>\n",
                        key: "my_article2.md",
                        title: "My Article #2"
                      },
                      %TestArticle{
                        author: "Me",
                        body: "<h2>\nMy Article 1</h2>\n<p>\nThis is my first article</p>\n",
                        key: "my_article1.md",
                        title: "My Article #1"
                      }
                    ],
                    test_stories: [
                      %TestStory{
                        author: "Me",
                        body: "<h2>\nMy Story 2</h2>\n<p>\nThis is my second story</p>\n",
                        key: "my_story2.md",
                        title: "My Story #2"
                      },
                      %TestStory{
                        author: "Me",
                        body: "<h2>\nMy Story 1</h2>\n<p>\nThis is my first story</p>\n",
                        key: "my_story1.md",
                        title: "My Story #1"
                      }
                    ],
                    test_guides: [
                      %TestGuide{
                        author: "Me",
                        body: "<h2>\nMy Guide 1</h2>\n<p>\nThis is my first guide</p>\n",
                        key: "my_guide1.md",
                        title: "My Guide #1"
                      }
                    ]
                  ] <- Builder.build_all!()
    end
  end
end
