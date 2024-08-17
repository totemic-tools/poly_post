# PolyPost

A customizable publishing engine with markdown and code highlighting support.

## Features

* Supports markdown with structured metadata in JSON
* Loads files directly from configured paths
* Supports multiple directories with markdown that can be specified as different resources
* Supports code highlighting in `code` blocks using [makeup](https://github.com/elixir-makeup/makeup)
* Stores content in single process-owned ETS tables
* Can update content during runtime by calling `PolyPost.build_and_store!/1` or `PolyPost.build_and_store_all!/0`

## Installation

You can add `poly_post` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:poly_post, "~> 0.1"}]
end
```

Then in any of your desired `config/{config,dev,prod,test}.exs` files
you can add the following to configure each resource:

```elixir
config :poly_post, :resources,
  content: [
    articles: {Article, {:path, "/path/to/my/markdown/*.md")}}
  ]
```

## Basic Usage

If I have a file called `my_article1.md` in the configured directory:

```markdown
{
  "title": "My Article #1",
  "author": "Me"
}
---
## My Article 1

This is my first article
```

*NOTE*: The metadata is interpreted as JSON, not as Elixir.

Then, I can create an `Article` module with the following to load my
content in a structured way to my app:

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

When I call `PolyPost.build_and_store_all!/0`, it will load all the
markdown files, call `Article.build/3` with the `reference`
(filename), `metadata` and `content` and return a struct specified as
you wish.

The only requirement is that the struct or map *MUST* contain a key
called `key` that uniquely identifies this content. It *MUST* be a
`String`.

If you wish to use `makeup` styling, specify the needed dependencies
in your `mix.exs` file. If I wanted to highlight Elixir, Erlang and
HTML in my project, then I would specify the following:

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

Then I can use tags in my markdown code blocks like so:

```markdown
````elixir
def start_link(arg) do
  GenServer.start_link(__MODULE__, arg, name: __MODULE__)
end
````
```

## Differences from NimblePublisher

This library was heavily inspired by [NimblePublisher](https://github.com/dashbitco/nimble_publisher), but
is different.

* Metadata in markdown files is specified in JSON instead of Elixir
* Designed to be updated at runtime via calling refresh methods (`PolyPost.build_and_store!/1` or `PolyPost.build_and_store_all!/0`)
* Must be configured through `Application` config using `:poly_post`

## License

This software is licensed under the [Apache-2.0 License](LICENSE).
