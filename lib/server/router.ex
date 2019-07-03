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
        send_resp(conn, 400, "Bad Request! Missing required file parameter.")

      _ ->
        Multiplex.add_playlist(conn.params)

        send_resp(conn, 202, "Accepted!")
    end
  end

  get "/stream/:stream/:filename" do
    res = Multiplex.get_stream(stream, filename)

    case res.status do
      200 ->
        conn
        |> put_resp_content_type("video/mp2t")
        |> send_file(res.status, res.file)

      404 ->
        send_resp(conn, res.status, res.message)
    end
  end

  get _ do
    send_resp(conn, 404, "Not found!")
  end
end
