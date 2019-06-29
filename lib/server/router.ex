defmodule Multiplex.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/playlist/:filename" do
    {:ok, config} = Application.fetch_env(:multiplex, __MODULE__)

    conn
    |> put_resp_content_type("application/vnd.apple.mpegurl")
    |> send_file(200, "#{config[:playlists_dir]}/#{filename}")
  end

  get "/stream/:stream/:filename" do
    {:ok, config} = Application.fetch_env(:multiplex, __MODULE__)

    conn
    |> put_resp_content_type("video/mp2t")
    |> send_file(200, "#{config[:segments_dir]}/#{stream}/#{filename}")
  end
end
