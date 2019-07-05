defmodule Multiplex.Endpoint do
  @moduledoc """
  Configuration for the Multiplex.Router REST API
  """

  use Plug.Router
  require Logger

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  forward("/", to: Multiplex.Router)

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(_opts) do
    with {:ok, [port: port] = config} <- Application.fetch_env(:multiplex, __MODULE__) do
      Logger.info("Starting server at http://localhost:#{port}/")
      Plug.Cowboy.http(__MODULE__, [], config)
    end
  end
end
