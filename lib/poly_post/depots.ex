defmodule PolyPost.Depots do
  use Supervisor

  alias PolyPost.Depot

  @doc """
  Starts the Depot supervisor
  """
  @doc since: "0.1.0"
  @spec start_link() :: Supervisor.on_start()
  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  # Callbacks

  @doc since: "0.1.0"
  @impl true
  def init(_) do
    Supervisor.init(depots(), strategy: :one_for_one)
  end

  @doc since: "0.1.0"
  def child_spec(_) do
    %{id: __MODULE__, start: {__MODULE__, :start_link, []}, type: :supervisor}
  end

  # Private

  defp depots do
    case get_config() do
      {:ok, config} -> get_child_specs(config)
      :error -> []
    end
  end

  defp get_config do
    Application.fetch_env(:poly_post, :resources)
  end

  defp get_child_specs(config) do
    case Keyword.fetch(config, :content) do
      {:ok, content} ->
        content
        |> Keyword.keys()
        |> Enum.map(fn table -> Supervisor.child_spec({Depot, table}, id: table) end)

      :error ->
        []
    end
  end
end
