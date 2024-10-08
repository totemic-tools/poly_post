defmodule PolyPost.Depot do
  @moduledoc """
  A process to manage the content for a resource (articles, etc.).
  """

  use GenServer

  alias PolyPost.Resource

  # API

  @doc """
  Starts the Depot process with a given name to represent the
  resource.
  """
  @doc since: "0.1.0"
  @spec start_link(Resource.name()) :: GenServer.on_start()
  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via(name))
  end

  @doc """
  Removes all the content related to the resouce.
  """
  @doc since: "0.1.0"
  @spec clear(Resource.name()) :: :ok
  def clear(name) do
    GenServer.call(via(name), :clear)
  end

  @doc """
  Checks to see if a depot process for a resource exists.
  """
  @doc since: "0.2.0"
  @spec exists?(Resource.name()) :: boolean()
  def exists?(name) do
    case Registry.lookup(PolyPost.Registry, name) do
      [] -> false
      _ -> true
    end
  end

  @doc """
  Finds specific content by a key for the resource.
  """
  @doc since: "0.1.0"
  @spec find(Resource.name(), Resource.key()) :: Resource.content()
  def find(name, key) do
    GenServer.call(via(name), {:find, key})
  end

  @doc """
  Gets all content for a resource.
  """
  @doc since: "0.1.0"
  @spec get_all(Resource.name()) :: [{Resource.key(), Resource.content()}]
  def get_all(name) do
    GenServer.call(via(name), :get_all)
  end

  @doc """
  Inserts content for a resource via a key
  """
  @doc since: "0.1.0"
  @spec insert(Resource.name(), Resource.key(), Resource.content()) :: :ok
  def insert(name, key, content) do
    GenServer.cast(via(name), {:insert, key, content})
  end

  # Callbacks

  def init(name) do
    {:ok, :ets.new(name, [:ordered_set, :protected, :named_table]), {:continue, name}}
  end

  def handle_call(:clear, _from, table) do
    :ets.delete_all_objects(table)
    {:reply, :ok, table}
  end

  def handle_call({:find, key}, _from, table) do
    case :ets.lookup(table, key) |> List.first() do
      {_, resource} -> {:reply, resource, table}
      _ -> {:reply, nil, table}
    end
  end

  def handle_call(:get_all, _from, table) do
    {:reply, :ets.match(table, :"$1") |> List.flatten(), table}
  end

  def handle_cast({:insert, key, content}, table) do
    :ets.insert(table, {key, content})
    {:noreply, table}
  end

  def handle_continue(_name, state) do
    {:noreply, state}
  end

  # Private

  defp via(name) do
    {:via, Registry, {PolyPost.Registry, name}}
  end
end
