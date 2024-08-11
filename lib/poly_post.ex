defmodule PolyPost do
  use Application

  alias PolyPost.{
    Builder,
    Depot
  }

  # API

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, [keys: :unique, name: PolyPost.Registry]}
    ]

    opts = [
      strategy: :one_for_one
    ]

    Supervisor.start_link(children, opts)
  end

  @doc """
  Builds a list of content for a specific markdown + metadata resource
  and store it in a `Depot` process.
  """
  @spec build_and_store!(Resource.name()) :: :ok
  def build_and_store!(resource) do
    resource
    |> Builder.build!()
    |> save_content(resource)

    :ok
  end

  @doc """
  Builds all the content for each  markdown + metadata resource
  and store it in a corresponding `Depot` process.
  """
  @spec build_and_save_all!() :: :ok
  def build_and_save_all! do
    Builder.build_all!() |> Enum.each(fn {resource, content} ->
      save_content(content, resource)
    end)

    :ok
  end

  # Private

  defp save_content(content, resource) do
    Enum.each(content, fn %{key: key} = data ->
      Depot.insert(resource, key, data)
    end)
  end
end
