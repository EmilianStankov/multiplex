defmodule MultiplexTest do
  use ExUnit.Case
  use Plug.Test
  alias Multiplex.Router
  doctest Multiplex

  @opts Router.init([])
  test "can create playlist with valid request" do
    {:ok, [test_dir: test_dir]} = Application.fetch_env(:multiplex, __MODULE__)

    upload = %Plug.Upload{path: "#{test_dir}/noise.mp3", filename: "noise.mp3"}
    conn = conn(:post, "http://localhost:4000/playlist/add", %{:file => upload})
    response = Router.call(conn, @opts)

    assert response.status == 200
  end

  @opts Router.init([])
  test "can't create playlist with missing parameter" do
    conn = conn(:post, "http://localhost:4000/playlist/add")
    response = Router.call(conn, @opts)

    assert response.status == 400
  end
end