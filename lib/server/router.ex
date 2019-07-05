defmodule Multiplex.Router do
  @moduledoc """
  REST API for creating and retrieving streams
  """

  use Plug.Router

  plug(:match)
  plug(:dispatch)

  @doc """
  GET - Get playlist by name

  ## Path params:
    - filename: String
  ## Response:
    - 200 if the playlist is found
    - 404 if not found
  """
  get "/playlist/:filename" do
    case check_session(conn) do
      nil ->
        send_resp(conn, 401, "Unauthorized")
      session ->
        res = Multiplex.get_playlist(session, filename)

        case res.status do
          200 ->
            conn
            |> put_resp_content_type("application/vnd.apple.mpegurl")
            |> send_file(res.status, res.file)

          404 ->
            send_resp(conn, res.status, res.message)
        end
    end
  end

  @doc """
  POST - Add a new playlist

  ## Body:
    %{
      (required) "file" => Plug.Upload,
      (optional) "segment_duration" => Integer
    }
  ## Response:
    - 202 if the request is accepted
    - 400 if file is not provided
  """
  post "/playlist/add" do
    case check_session(conn) do
      nil ->
        send_resp(conn, 401, "Unauthorized")
      session ->
        file = conn.params["file"]

        case file do
          nil ->
            send_resp(conn, 400, "Bad Request! Missing required file parameter.")

          _ ->
            Multiplex.add_playlist(session, conn.params)

            send_resp(conn, 202, "Accepted!")
        end
    end
  end

  @doc """
  GET - Get stream segment by name

  ## Path params:
    - stream: String - name of the stream
    - filename: String - filename of the segment
  ## Response:
    - 200 if the stream segment is found
    - 404 if not found
  """
  get "/stream/:stream/:filename" do
    case check_session(conn) do
      nil ->
        send_resp(conn, 401, "Unauthorized")
      session ->
        res = Multiplex.get_stream(session, stream, filename)

        case res.status do
          200 ->
            conn
            |> put_resp_content_type("video/mp2t")
            |> send_file(res.status, res.file)

          404 ->
            send_resp(conn, res.status, res.message)
        end
    end
  end

  get _ do
    send_resp(conn, 404, "Not found!")
  end

  defp check_session(conn) do
    case conn |> get_req_header("session-id") do
      [] ->
        nil
      session_id ->
        session_id = session_id |> Enum.at(0) |> String.to_atom()
        case Process.whereis(session_id) do
          nil ->
            {:ok, pid} = Multiplex.DynamicSupervisor.create_instance(session_id)
            pid
          x ->
            x
        end
    end
  end
end
