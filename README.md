# PolyPost [![Hex Version](https://img.shields.io/hexpm/v/poly_post.svg)](https://hex.pm/packages/poly_post) [![Hex Docs](https://img.shields.io/badge/docs-hexpm-blue.svg)](https://hexdocs.pm/poly_post/)

A publishing engine with markdown and code highlighting support.

## Features

* Loads files directly from configured paths
* Stores content in single process-owned ETS tables
* Supports markdown with structured metadata in JSON
* Supports multiple directories with markdown files that can be specified as different resources
* Supports code highlighting in `code` blocks using [makeup](https://github.com/elixir-makeup/makeup)
* Update content during runtime by calling:
  * `PolyPost.build_and_store!/1`
  * `PolyPost.build_and_store_all!/0`

## Installation

You can add `poly_post` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:poly_post, "~> 0.1"}]
end
```

In any of the `config/{config,dev,prod,test}.exs` files
you can configure each resources for your content:

```elixir
config :poly_post, :resources,
  content: [
    articles: {Article, {:path, "/path/to/my/markdown/*.md")}}
  ]
```

## Basic Usage

### Loading and Storing Content

With a file called `my_article1.md` in the configured directory:

```markdown
{
  "title": "My Article #1",
  "author": "Me"
}
---
## My Article 1

This is my first article
```

You can create an `Article` module to load your content by
implementing the `PolyPost.Resource.build/3` callback:

```elixir
defmodule Article do
  @behaviour PolyPost.Resource

  @enforce_keys [:key, :title, :author, :body]
  defstruct [:key, :title, :author, :body]

  # Callbacks

  @impl PolyPost.Resource
  def build(reference, metadata, body) do
    %__MODULE__{
      key: reference,
      title: get_in(metadata, ["title"]),
      author: get_in(metadata, ["author"]),
      body: body
    }
  end
end
```

The only requirement is that the struct or map **MUST** contain a key
called `key` that uniquely identifies this content. It **MUST** be a
`String`.

When I call `PolyPost.build_and_store_all!/0`, it will:

1. Load and parse all the markdown files and their metadata
2. Replace all `code` blocks with highlighted versions if a highlighter is .
2. Call `Article.build/3` with the `reference` (filename), `metadata` and `content`
3. Then it stores it in a corresponding `PolyPost.Depot` process.

### Using Makeup to Style Code Blocks

If you wish to use [makeup](https://github.com/elixir-makeup/makeup) to style your `code` blocks, you must
specify the needed dependencies in your `mix.exs` file.

For example, if you wanted to highlight Elixir, Erlang and HTML in your
project, then I would specify the following:

```elixir
defp deps do
  [
    {:makeup, "~> 1.1"},
    {:makeup_elixir, ">= 0.0.0"},
    {:makeup_erlang, ">= 0.0.0"},
    {:makeup_html, ">= 0.0.0"}
  ]
end
```

Then you can use tags in your markdown code blocks like so and it will
automatically highlight them:

````markdown
```elixir
def start_link(arg) do
  GenServer.start_link(__MODULE__, arg, name: __MODULE__)
end
```
````

### Retrieving Content

You can retrieve content using the functions on the `PolyPost.Depot`
module to access the associated ETS table that stores your data:

1. `find/2` - find a specific content by `key` for the resource
2. `get_all/1` - gets all content for a resource

For example:

```elixir
PolyPost.Depot.find(:articles, "my_article1.md")
=> %Article{...}
```

and

```elixir
PolyPost.Depot.get_all(:articles)
=> [%Article{...}]
```

## Differences from NimblePublisher

This library was heavily inspired by [NimblePublisher](https://github.com/dashbitco/nimble_publisher), but
it **IS** different.

* Metadata in markdown files are specified in JSON instead of Elixir
* Designed to be updated at runtime via calling refresh methods (`PolyPost.build_and_store!/1` or `PolyPost.build_and_store_all!/0`)
* Must be configured through `Application` config using `:poly_post`
* Stores content in ETS instead of compiling directly into modules

## License

This software is licensed under the [Apache-2.0 License](LICENSE).
