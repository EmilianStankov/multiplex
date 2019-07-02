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

  @opts Router.init([])
  test "missing playlist returns proper status" do
    conn = conn(:get, "http://localhost:4000/playlist/missing")
    response = Router.call(conn, @opts)

    assert response.status == 404
  end

  @opts Router.init([])
  test "missing stream returns proper status" do
    conn = conn(:get, "http://localhost:4000/stream/missing/missing")
    response = Router.call(conn, @opts)

    assert response.status == 404
  end

  @opts Router.init([])
  test "missing segment for existing stream returns proper status" do
    conn = conn(:get, "http://localhost:4000/stream/noise/missing")
    response = Router.call(conn, @opts)

    assert response.status == 404
  end

  @opts Router.init([])
  test "missing segment for existing stream returns status" do
    conn = conn(:get, "http://localhost:4000/stream/noise")
    response = Router.call(conn, @opts)

    assert response.status == 404
  end
end
