defmodule PolyPost do
  use Application

  # API

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, [keys: :unique, name: PolyPost.Registry]}
    ]

    opts = [
      strategy: :one_for_one,
      name: __MODULE__
    ]

    Supervisor.start_link(children, opts)
  end
end
