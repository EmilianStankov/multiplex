defmodule Multiplex.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/playlist/:filename" do
    with {:ok, config} <- Application.fetch_env(:multiplex, Multiplex) do
      conn
      |> put_resp_content_type("application/vnd.apple.mpegurl")
      |> send_file(200, "#{config[:playlists_dir]}/#{filename}")
    end
  end

  post "/playlist/add" do
    file = conn.params["file"]

    case file do
      nil ->
        send_resp(conn, 400, "Bad Request! Missing file parameter.")

      _ ->
        Multiplex.Segment.extract_segments(file)
        |> Multiplex.M3u8.create_playlist()

        send_resp(conn, 200, "Success!")
    end
  end

  get "/stream/:stream/:filename" do
    with {:ok, config} <- Application.fetch_env(:multiplex, Multiplex) do
      conn
      |> put_resp_content_type("video/mp2t")
      |> send_file(200, "#{config[:segments_dir]}/#{stream}/#{filename}")
    end
  end
end
