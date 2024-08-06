defmodule PolyPost.Depot do
  use GenServer

  alias PolyPost.Resource

  @type name :: atom()

  # API

  @spec start_link(name()) :: GenServer.on_start()
  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via(name))
  end

  @spec clear(name()) :: :ok
  def clear(name) do
    GenServer.call(via(name), :clear)
  end

  @spec find(name(), Resource.key()) :: Resource.content()
  def find(name, key) do
    GenServer.call(via(name), {:find, key})
  end

  @spec get_all(name()) :: [{Resource.key(), Resource.content()}]
  def get_all(name) do
    GenServer.call(via(name), :get_all)
  end

  @spec insert(name(), Resource.key(), Resource.content()) :: :ok
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
