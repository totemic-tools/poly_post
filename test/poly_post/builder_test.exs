defmodule PolyPost.BuilderTest do
  use ExUnit.Case, async: false

  alias PolyPost.Builder

  @articles_path "test/fixtures/test_articles/*.md"
  @stories_path "test/fixtures/test_stories/*.md"
  @guides_path "test/fixtures/test_guides/*.md"

  @article_resource :test_articles
  @story_resource :test_stories
  @guide_resource :test_guides

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
      ],
    ]
  ]

  setup_all do
    Application.put_env(:poly_post, :resources, @resources)
  end

  describe ".build!/1" do
    test "it builds a specific resource" do
      assert [
               %TestArticle{
                 key: "my_article2.md",
                 title: "My Article #2",
                 author: "Me",
                 body: "<h2>\nMy Article 2</h2>\n<p>\nThis is my second article</p>\n"
               },
               %TestArticle{
                 key: "my_article1.md",
                 title: "My Article #1",
                 author: "Me",
                 body: "<h2>\nMy Article 1</h2>\n<p>\nThis is my first article</p>\n"
               }
             ] = Builder.build!(@article_resource)
    end
  end

  describe ".build_all!/0" do
    test "it builds all the resources" do
      assert [
               {@article_resource,
                [
                  %TestArticle{
                    key: "my_article2.md",
                    title: "My Article #2",
                    author: "Me",
                    body: "<h2>\nMy Article 2</h2>\n<p>\nThis is my second article</p>\n"
                  },
                  %TestArticle{
                    key: "my_article1.md",
                    title: "My Article #1",
                    author: "Me",
                    body: "<h2>\nMy Article 1</h2>\n<p>\nThis is my first article</p>\n"
                  }
                ]},
               {@story_resource,
                [
                  %TestStory{
                    key: "my_story2.md",
                    title: "My Story #2",
                    author: "Me",
                    body: "<h2>\nMy Story 2</h2>\n<p>\nThis is my second story</p>\n"
                  },
                  %TestStory{
                    key: "my_story1.md",
                    title: "My Story #1",
                    author: "Me",
                    body: "<h2>\nMy Story 1</h2>\n<p>\nThis is my first story</p>\n"
                  }
                ]},
               {@guide_resource,
                [
                  %TestGuide{
                    key: "my_guide1.md",
                    title: "My Guide #1",
                    author: "Me",
                    body: "<h2>\nMy Guide 1</h2>\n<p>\nThis is my first guide</p>\n"
                  }
                ]},
             ] = Builder.build_all!()
    end
  end
end
