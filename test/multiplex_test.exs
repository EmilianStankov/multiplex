defmodule MultiplexTest do
  use ExUnit.Case
  use Plug.Test
  alias Multiplex.Router
  doctest Multiplex
  import FFmpex
  use FFmpex.Options

  @opts Router.init([])
  test "can create playlist with valid request" do
    {:ok, config} = Application.fetch_env(:multiplex, __MODULE__)

    upload = %Plug.Upload{path: "#{config[:test_dir]}/noise.mp3", filename: "noise.mp3"}
    conn = conn(:post, "http://localhost:4000/playlist/add", %{:file => upload})
    response = Router.call(conn, @opts)

    assert response.status == 202

    Process.sleep(1000)

    File.rm_rf("#{config[:segments_dir]}/noise")
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

  @opts Router.init([])
  test "can get segments for existing stream" do
    {:ok, config} = Application.fetch_env(:multiplex, __MODULE__)

    upload = %Plug.Upload{path: "#{config[:test_dir]}/noise.mp3", filename: "noise.mp3"}

    conn(:post, "http://localhost:4000/playlist/add", %{:file => upload})
    |> Router.call(@opts)

    Process.sleep(1000)

    conn = conn(:get, "http://localhost:4000/stream/noise/noise.000.ts")
    response = Router.call(conn, @opts)

    assert response.status == 200

    conn = conn(:get, "http://localhost:4000/stream/noise/noise.001.ts")
    response = Router.call(conn, @opts)

    assert response.status == 200

    conn = conn(:get, "http://localhost:4000/stream/noise/noise.002.ts")
    response = Router.call(conn, @opts)

    assert response.status == 200

    conn = conn(:get, "http://localhost:4000/stream/noise/noise.003.ts")
    response = Router.call(conn, @opts)

    assert response.status == 200

    conn = conn(:get, "http://localhost:4000/stream/noise/noise.004.ts")
    response = Router.call(conn, @opts)

    assert response.status == 200

    conn = conn(:get, "http://localhost:4000/stream/noise/noise.005.ts")
    response = Router.call(conn, @opts)

    assert response.status == 200

    conn = conn(:get, "http://localhost:4000/stream/noise/noise.006.ts")
    response = Router.call(conn, @opts)

    assert response.status == 200

    conn = conn(:get, "http://localhost:4000/stream/noise/noise.007.ts")
    response = Router.call(conn, @opts)

    assert response.status == 200

    File.rm_rf("#{config[:segments_dir]}/noise")
  end

  test "segmentation with default settings splits file in right number of segments" do
    {:ok, config} = Application.fetch_env(:multiplex, __MODULE__)
    file = "#{config[:test_dir]}/noise.mp3"

    Multiplex.Segment.extract_segments(file)

    assert File.dir?("#{config[:segments_dir]}/noise")
    assert Path.wildcard("#{config[:segments_dir]}/noise/*.ts") |> length === 8

    File.rm_rf("#{config[:segments_dir]}/noise")
  end

  test "segmentation with custom settings splits file in right number of segments" do
    {:ok, config} = Application.fetch_env(:multiplex, __MODULE__)
    file = "#{config[:test_dir]}/noise.mp3"

    Multiplex.Segment.extract_segments(file, ".mp3", 3)

    assert File.dir?("#{config[:segments_dir]}/noise")
    assert Path.wildcard("#{config[:segments_dir]}/noise/*.ts") |> length === 10

    File.rm_rf("#{config[:segments_dir]}/noise")
  end

  test "segmentation with wrong file extension" do
    {:ok, config} = Application.fetch_env(:multiplex, __MODULE__)
    file = "#{config[:test_dir]}/noise.mp3"

    Multiplex.Segment.extract_segments(file, ".wav", 3)

    assert !File.dir?("#{config[:segments_dir]}/noise")
    assert File.dir?("#{config[:segments_dir]}/noise.mp3")

    File.rm_rf("#{config[:segments_dir]}/noise.mp3")
  end

  test "playlist file with default config has correct content" do
    {:ok, config} = Application.fetch_env(:multiplex, __MODULE__)
    file = "#{config[:test_dir]}/noise.mp3"

    Multiplex.Segment.extract_segments(file)
    |> Multiplex.M3u8.create_playlist()

    expected_body = [
      "#EXTM3U",
      "#EXT-X-VERSION:3",
      "#EXT-X-TARGETDURATION:4",
      "#EXTINF:4",
      "#{config[:base_url]}/stream/noise/noise.000.ts",
      "#EXTINF:4",
      "#{config[:base_url]}/stream/noise/noise.001.ts",
      "#EXTINF:4",
      "#{config[:base_url]}/stream/noise/noise.002.ts",
      "#EXTINF:4",
      "#{config[:base_url]}/stream/noise/noise.003.ts",
      "#EXTINF:4",
      "#{config[:base_url]}/stream/noise/noise.004.ts",
      "#EXTINF:4",
      "#{config[:base_url]}/stream/noise/noise.005.ts",
      "#EXTINF:4",
      "#{config[:base_url]}/stream/noise/noise.006.ts",
      "#EXTINF:4",
      "#{config[:base_url]}/stream/noise/noise.007.ts",
      "#EXT-X-ENDLIST"
    ] |> Enum.join("\n")

    {:ok, body} = File.read("#{config[:playlists_dir]}/noise.m3u8")

    assert File.exists?("#{config[:playlists_dir]}/noise.m3u8")
    assert body === expected_body

    File.rm_rf("#{config[:segments_dir]}/noise")
  end
end
