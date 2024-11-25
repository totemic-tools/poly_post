defmodule PolyPost.BuilderTest do
  use ExUnit.Case, async: false
  use Mneme

  alias PolyPost.GitTestHelper
  alias PolyPost.Builder

  @bad_path "test/fixtures/test_bad/*.md"
  @missing_path "test/fixtures/test_missing/*.md"
  @articles_path "test/fixtures/test_articles/*.md"
  @stories_path "test/fixtures/test_stories/*.md"
  @guides_path "test/fixtures/test_guides/*.md"

  @article_resource :test_articles
  @bad_resource :test_bad
  @missing_resource :test_missing
  @repo_resource :test_repo

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

  @missing_resources [
    front_matter: [decoder: {YamlElixir, :read_from_string, []}],
    content: [
      test_missing: [
        module: TestMissing,
        path: File.cwd!() |> Path.join(@missing_path)
      ]
    ]
  ]

  setup_all do
    Makeup.Registry.register_lexer(Makeup.Lexers.ElixirLexer,
      options: [group_prefix: "group"],
      names: ["elixir", "iex"],
      extensions: ["ex", "exs"]
    )

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

    test "it fails to build a specific resource because of missing metadata" do
      Application.put_env(:poly_post, :resources, @missing_resources)

      assert_raise PolyPost.MissingMetadataError, fn ->
        Builder.build!(@missing_resource)
      end

      Application.put_env(:poly_post, :resources, @resources)
    end

    test "it builds a specific resource" do
      article_body_1 = File.read!("test/fixtures/test_articles/my_article1.html")
      article_body_2 = File.read!("test/fixtures/test_articles/my_article2.html")

      assert [
        %TestArticle{
          author: "Me",
          body: ^article_body_2,
          key: "my_article2.md",
          title: "My Article #2"
        },
        %TestArticle{
          author: "Me",
          body: ^article_body_1,
          key: "my_article1.md",
          title: "My Article #1"
        }
      ] = Builder.build!(@article_resource)
    end

    test "it builds a specific resource from git" do
      git_resources = build_repo_resources()

      Application.put_env(:poly_post, :resources, git_resources)

      auto_assert [
        %TestArticle{
          body: "<p>\nThis is test content.</p>\n",
          key: "git_test_content.md"
        }
      ] <- Builder.build!(@repo_resource)

      Application.put_env(:poly_post, :resources, @resources)
    end
  end

  describe ".build_all!/0" do
    test "it builds all the resources" do
      article_body_1 = File.read!("test/fixtures/test_articles/my_article1.html")
      article_body_2 = File.read!("test/fixtures/test_articles/my_article2.html")

      assert [
        test_articles: [
          %TestArticle{
            author: "Me",
            body: ^article_body_2,
            key: "my_article2.md",
            title: "My Article #2"
          },
          %TestArticle{
            author: "Me",
            body: ^article_body_1,
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
            body:
            "<h2>\nMy Guide 1</h2>\n<p>\nThis is my first guide</p>\n<pre><code class=\"ruby\">a = Klass.new\na.run!</code></pre>\n",
            key: "my_guide1.md",
            title: "My Guide #1"
          }
        ]
      ] = Builder.build_all!()
    end
  end

  # Private

  defp build_repo_resources do
    dest = GitTestHelper.random_tmp_dir()
    path = GitTestHelper.setup_tmp_repo()
    content = Path.join(path, "*.md")

    GitTestHelper.make_test_commit(path)

    [
      front_matter: [decoder: {YamlElixir, :read_from_string, []}],
      content: [
        test_repo: [
          module: TestArticle,
          source: [
            dest: dest,
            git: path,
            ref: "main"
          ],
          path: content
        ]
      ]
    ]
  end
end
