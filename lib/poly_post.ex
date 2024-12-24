defmodule PolyPost do
  use Application

  alias PolyPost.{
    Builder,
    Depots,
    Depot,
    Resource,
    Util
  }

  # API

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, [keys: :unique, name: PolyPost.Registry]},
      Depots
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
  @doc since: "0.1.0"
  @spec build_and_store!(Resource.name()) :: :ok | {:error, :not_found}
  def build_and_store!(resource) do
    case Builder.build!(resource) do
      [] -> {:error, :not_found}
      content -> store_content(content, resource)
    end
  end

  @doc """
  Builds all the content for each  markdown + metadata resource
  and store it in a corresponding `Depot` process.
  """
  @doc since: "0.1.0"
  @spec build_and_store_all!() :: :ok
  def build_and_store_all! do
    Builder.build_all!()
    |> Enum.each(fn {resource, content} ->
      store_content(content, resource)
    end)
  end

  @doc """
  Clears all content for a specific resource
  """
  @doc since: "0.2.0"
  @spec clear(Resource.name()) :: :ok | {:error, :not_found}
  def clear(resource) do
    if Depot.exists?(resource) do
      Depot.clear(resource)
    else
      {:error, :not_found}
    end
  end

  @doc """
  Clears all content out of all resources
  """
  @doc since: "0.2.0"
  @spec clear_all() :: :ok
  def clear_all do
    Application.fetch_env!(:poly_post, :resources)
    |> get_in([:content])
    |> Enum.each(fn {resource, _} -> Depot.clear(resource) end)
  end

  @doc """
  List all resources and their metadata
  """
  @doc since: "0.2.0"
  @spec list_resources() :: {:ok, keyword(Resource.config())}
  | {:error, :resources_not_found}
  | {:error, :config_not_found}
  def list_resources do
    case Util.get_config() do
      {:ok, config} -> get_resources(config)
      :error -> {:error, :config_not_found}
    end
  end

  # Private

  defp get_resources(config) do
    case Keyword.fetch(config, :content) do
      {:ok, content} -> {:ok, content}
      :error -> {:error, :content_key_not_found}
    end
  end

  defp store_content(content, resource) do
    Enum.each(content, fn %{key: key} = data ->
      Depot.insert(resource, key, data)
    end)
  end
end
