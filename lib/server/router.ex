defmodule Multiplex.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/playlist/:filename" do
    res = Multiplex.get_playlist(filename)

    case res.status do
      200 ->
        conn
        |> put_resp_content_type("application/vnd.apple.mpegurl")
        |> send_file(res.status, res.file)

      404 ->
        send_resp(conn, res.status, res.message)
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
      case File.exists?("#{config[:segments_dir]}/#{stream}/#{filename}") do
        true ->
          conn
          |> put_resp_content_type("video/mp2t")
          |> send_file(200, "#{config[:segments_dir]}/#{stream}/#{filename}")

        _ ->
          send_resp(conn, 404, "File not found!")
      end
    end
  end

  get _ do
    send_resp(conn, 404, "Not found!")
  end
end
