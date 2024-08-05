defmodule PolyPost do
  use Supervisor

  # API

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  # Callbacks

  def child_spec(_) do
    %{
      id: __MODULE__,
      type: :supervisor,
      start: {__MODULE__, :start_link, []}
    }
  end

  def init(_) do
    children = [
      {Registry, [keys: :unique, name: PolyPost.Registry]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
