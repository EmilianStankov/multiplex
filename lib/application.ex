defmodule Multiplex.Application do
  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Lambda.Worker.start_link(arg)
      # {Lambda.Worker, arg},
      Multiplex,
      Multiplex.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Multiplex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
