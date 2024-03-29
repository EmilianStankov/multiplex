defmodule MultiplexTest do
  use ExUnit.Case
  use Plug.Test
  alias Multiplex.Router
  doctest Multiplex

  setup context do
    {:ok, config} = Application.fetch_env(:multiplex, __MODULE__)
    [config: config]
  end

  @opts Router.init([])
  test "can't create playlist without session", context do
    upload = %Plug.Upload{path: "#{context.config[:test_dir]}/noise.mp3", filename: "noise.mp3"}
    conn = conn(:post, "http://localhost:4000/playlist/add", %{:file => upload})
    response = Router.call(conn, @opts)

    assert response.status == 401

    Process.sleep(1000)
  end

  @opts Router.init([])
  test "can't create playlist with custom config without session", context do
    upload = %Plug.Upload{path: "#{context.config[:test_dir]}/noise.mp3", filename: "noise.mp3"}

    conn =
      conn(:post, "http://localhost:4000/playlist/add", %{:file => upload, :segment_duration => 8})

    response = Router.call(conn, @opts)

    assert response.status == 401

    Process.sleep(1000)

    File.rm_rf("#{context.config[:segments_dir]}/noise")
  end

  @opts Router.init([])
  test "can't get playlist without a valid session" do
    conn = conn(:get, "http://localhost:4000/playlist/missing")
    response = Router.call(conn, @opts)

    assert response.status == 401
  end

  @opts Router.init([])
  test "can't get stream without a valid session" do
    conn = conn(:get, "http://localhost:4000/stream/missing/missing")
    response = Router.call(conn, @opts)

    assert response.status == 401
  end

  @opts Router.init([])
  test "can't get segments for existing stream without session", context do
    upload = %Plug.Upload{path: "#{context.config[:test_dir]}/noise.mp3", filename: "noise.mp3"}

    conn(:post, "http://localhost:4000/playlist/add", %{:file => upload})
    |> Router.call(@opts)

    Process.sleep(1000)

    conn = conn(:get, "http://localhost:4000/stream/noise/noise.000.ts")
    response = Router.call(conn, @opts)

    assert response.status == 401

    conn = conn(:get, "http://localhost:4000/stream/noise/noise.001.ts")
    response = Router.call(conn, @opts)

    assert response.status == 401

    conn = conn(:get, "http://localhost:4000/stream/noise/noise.002.ts")
    response = Router.call(conn, @opts)

    assert response.status == 401

    conn = conn(:get, "http://localhost:4000/stream/noise/noise.003.ts")
    response = Router.call(conn, @opts)

    assert response.status == 401

    conn = conn(:get, "http://localhost:4000/stream/noise/noise.004.ts")
    response = Router.call(conn, @opts)

    assert response.status == 401

    conn = conn(:get, "http://localhost:4000/stream/noise/noise.005.ts")
    response = Router.call(conn, @opts)

    assert response.status == 401

    conn = conn(:get, "http://localhost:4000/stream/noise/noise.006.ts")
    response = Router.call(conn, @opts)

    assert response.status == 401

    conn = conn(:get, "http://localhost:4000/stream/noise/noise.007.ts")
    response = Router.call(conn, @opts)

    assert response.status == 401

    File.rm_rf("#{context.config[:segments_dir]}/noise")
  end

  @opts Router.init([])
  test "can create playlist with valid request", context do
    upload = %Plug.Upload{path: "#{context.config[:test_dir]}/noise.mp3", filename: "noise.mp3"}

    conn =
      conn(:post, "http://localhost:4000/playlist/add", %{:file => upload})
      |> put_req_header("session-id", "test")

    response = Router.call(conn, @opts)

    assert response.status == 202

    Process.sleep(1000)

    File.rm_rf("#{context.config[:segments_dir]}/noise")
  end

  @opts Router.init([])
  test "can't create playlist with missing parameter" do
    conn =
      conn(:post, "http://localhost:4000/playlist/add")
      |> put_req_header("session-id", "test")

    response = Router.call(conn, @opts)

    assert response.status == 400
  end

  @opts Router.init([])
  test "can create playlist with custom config", context do
    upload = %Plug.Upload{path: "#{context.config[:test_dir]}/noise.mp3", filename: "noise.mp3"}

    conn =
      conn(:post, "http://localhost:4000/playlist/add", %{:file => upload, :segment_duration => 8})
      |> put_req_header("session-id", "test")

    response = Router.call(conn, @opts)

    assert response.status == 202

    Process.sleep(1000)

    File.rm_rf("#{context.config[:segments_dir]}/noise")
  end

  @opts Router.init([])
  test "can get playlist with valid session", context do
    upload = %Plug.Upload{path: "#{context.config[:test_dir]}/noise.mp3", filename: "noise.mp3"}

    conn =
      conn(:post, "http://localhost:4000/playlist/add", %{:file => upload})
      |> put_req_header("session-id", "test")

    response = Router.call(conn, @opts)

    assert response.status == 202

    Process.sleep(1000)

    conn = conn(:get, "http://localhost:4000/playlist/noise.m3u8")
    |> put_req_header("session-id", "test")
    response = Router.call(conn, @opts)

    assert response.status == 200

    File.rm_rf("#{context.config[:segments_dir]}/noise")
  end

  @opts Router.init([])
  test "missing playlist returns proper status" do
    conn =
      conn(:get, "http://localhost:4000/playlist/missing")
      |> put_req_header("session-id", "test")

    response = Router.call(conn, @opts)

    assert response.status == 404
  end

  @opts Router.init([])
  test "missing stream returns proper status" do
    conn =
      conn(:get, "http://localhost:4000/stream/missing/missing")
      |> put_req_header("session-id", "test")

    response = Router.call(conn, @opts)

    assert response.status == 404
  end

  @opts Router.init([])
  test "missing segment for existing stream returns proper status" do
    conn =
      conn(:get, "http://localhost:4000/stream/noise/missing")
      |> put_req_header("session-id", "test")

    response = Router.call(conn, @opts)

    assert response.status == 404
  end

  @opts Router.init([])
  test "can get segments for existing stream", context do
    upload = %Plug.Upload{path: "#{context.config[:test_dir]}/noise.mp3", filename: "noise.mp3"}

    conn(:post, "http://localhost:4000/playlist/add", %{:file => upload})
    |> put_req_header("session-id", "test")
    |> Router.call(@opts)

    Process.sleep(1000)

    conn =
      conn(:get, "http://localhost:4000/stream/noise/noise.000.ts")
      |> put_req_header("session-id", "test")

    response = Router.call(conn, @opts)

    assert response.status == 200

    conn =
      conn(:get, "http://localhost:4000/stream/noise/noise.001.ts")
      |> put_req_header("session-id", "test")

    response = Router.call(conn, @opts)

    assert response.status == 200

    conn =
      conn(:get, "http://localhost:4000/stream/noise/noise.002.ts")
      |> put_req_header("session-id", "test")

    response = Router.call(conn, @opts)

    assert response.status == 200

    conn =
      conn(:get, "http://localhost:4000/stream/noise/noise.003.ts")
      |> put_req_header("session-id", "test")

    response = Router.call(conn, @opts)

    assert response.status == 200

    conn =
      conn(:get, "http://localhost:4000/stream/noise/noise.004.ts")
      |> put_req_header("session-id", "test")

    response = Router.call(conn, @opts)

    assert response.status == 200

    conn =
      conn(:get, "http://localhost:4000/stream/noise/noise.005.ts")
      |> put_req_header("session-id", "test")

    response = Router.call(conn, @opts)

    assert response.status == 200

    conn =
      conn(:get, "http://localhost:4000/stream/noise/noise.006.ts")
      |> put_req_header("session-id", "test")

    response = Router.call(conn, @opts)

    assert response.status == 200

    conn =
      conn(:get, "http://localhost:4000/stream/noise/noise.007.ts")
      |> put_req_header("session-id", "test")

    response = Router.call(conn, @opts)

    assert response.status == 200

    File.rm_rf("#{context.config[:segments_dir]}/noise")
  end

  test "segmentation with default settings splits file in right number of segments", context do
    file = "#{context.config[:test_dir]}/noise.mp3"

    Multiplex.Segment.extract_segments(file)

    assert File.dir?("#{context.config[:segments_dir]}/noise")
    assert Path.wildcard("#{context.config[:segments_dir]}/noise/*.ts") |> length === 8

    File.rm_rf("#{context.config[:segments_dir]}/noise")
  end

  test "segmentation with custom settings splits file in right number of segments", context do
    file = "#{context.config[:test_dir]}/noise.mp3"

    Multiplex.Segment.extract_segments(file, ".mp3", 3)

    assert File.dir?("#{context.config[:segments_dir]}/noise")
    assert Path.wildcard("#{context.config[:segments_dir]}/noise/*.ts") |> length === 10

    File.rm_rf("#{context.config[:segments_dir]}/noise")
  end

  test "segmentation with wrong file extension", context do
    file = "#{context.config[:test_dir]}/noise.mp3"

    Multiplex.Segment.extract_segments(file, ".wav", 3)

    assert !File.dir?("#{context.config[:segments_dir]}/noise")
    assert File.dir?("#{context.config[:segments_dir]}/noise.mp3")

    File.rm_rf("#{context.config[:segments_dir]}/noise.mp3")
  end

  test "playlist file with default config has correct content", context do
    file = "#{context.config[:test_dir]}/noise.mp3"

    Multiplex.Segment.extract_segments(file)
    |> Multiplex.M3u8.create_playlist()

    expected_body =
      [
        "#EXTM3U",
        "#EXT-X-VERSION:3",
        "#EXT-X-TARGETDURATION:4",
        "#EXTINF:4",
        "#{context.config[:base_url]}/stream/noise/noise.000.ts",
        "#EXTINF:4",
        "#{context.config[:base_url]}/stream/noise/noise.001.ts",
        "#EXTINF:4",
        "#{context.config[:base_url]}/stream/noise/noise.002.ts",
        "#EXTINF:4",
        "#{context.config[:base_url]}/stream/noise/noise.003.ts",
        "#EXTINF:4",
        "#{context.config[:base_url]}/stream/noise/noise.004.ts",
        "#EXTINF:4",
        "#{context.config[:base_url]}/stream/noise/noise.005.ts",
        "#EXTINF:4",
        "#{context.config[:base_url]}/stream/noise/noise.006.ts",
        "#EXTINF:4",
        "#{context.config[:base_url]}/stream/noise/noise.007.ts",
        "#EXT-X-ENDLIST"
      ]
      |> Enum.join("\n")

    {:ok, body} = File.read("#{context.config[:playlists_dir]}/noise.m3u8")

    assert File.exists?("#{context.config[:playlists_dir]}/noise.m3u8")
    assert body === expected_body

    File.rm_rf("#{context.config[:segments_dir]}/noise")
  end

  test "playlist file with custom config has correct content", context do
    file = "#{context.config[:test_dir]}/noise.mp3"

    Multiplex.Segment.extract_segments(file, ".mp3", 8)
    |> Multiplex.M3u8.create_playlist(8)

    expected_body =
      [
        "#EXTM3U",
        "#EXT-X-VERSION:3",
        "#EXT-X-TARGETDURATION:8",
        "#EXTINF:8",
        "#{context.config[:base_url]}/stream/noise/noise.000.ts",
        "#EXTINF:8",
        "#{context.config[:base_url]}/stream/noise/noise.001.ts",
        "#EXTINF:8",
        "#{context.config[:base_url]}/stream/noise/noise.002.ts",
        "#EXTINF:8",
        "#{context.config[:base_url]}/stream/noise/noise.003.ts",
        "#EXT-X-ENDLIST"
      ]
      |> Enum.join("\n")

    {:ok, body} = File.read("#{context.config[:playlists_dir]}/noise.m3u8")

    assert File.exists?("#{context.config[:playlists_dir]}/noise.m3u8")
    assert body === expected_body

    File.rm_rf("#{context.config[:segments_dir]}/noise")
  end

  test "can create session" do
    children = DynamicSupervisor.which_children(Multiplex.DynamicSupervisor) |> Kernel.length
    Multiplex.DynamicSupervisor.create_instance(:test2)
    assert DynamicSupervisor.which_children(Multiplex.DynamicSupervisor) |> Kernel.length === children + 1
  end

  test "can terminate session" do
    children = DynamicSupervisor.which_children(Multiplex.DynamicSupervisor) |> Kernel.length
    Multiplex.DynamicSupervisor.create_instance(:test3)
    assert DynamicSupervisor.which_children(Multiplex.DynamicSupervisor) |> Kernel.length === children + 1
    Multiplex.DynamicSupervisor.terminate_session(Process.whereis(:test3))
    assert DynamicSupervisor.which_children(Multiplex.DynamicSupervisor) |> Kernel.length === children
  end
end
