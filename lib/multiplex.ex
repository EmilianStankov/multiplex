defmodule Multiplex do
  use GenServer

  def get_playlist(filename) do
    GenServer.call(__MODULE__, {:get_playlist, filename})
  end

  def add_playlist(file) do
    GenServer.cast(__MODULE__, {:add_playlist, file})
  end

  def start_link(_) do
    {:ok, registry} = GenServer.start_link(__MODULE__, :ok)
    Process.register(registry, __MODULE__)
    {:ok, registry}
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_call({:get_playlist, filename}, _from, state) do
    with {:ok, config} <- Application.fetch_env(:multiplex, __MODULE__) do
      case File.exists?("#{config[:playlists_dir]}/#{filename}") do
        true ->
          {:reply, %{status: 200, file: "#{config[:playlists_dir]}/#{filename}"}, state}

        _ ->
          {:reply, %{status: 404, message: "File not found!"}, state}
      end
    end
  end

  def handle_cast({:add_playlist, file}, state) do
    Multiplex.Segment.extract_segments(file)
    |> Multiplex.M3u8.create_playlist()

    {:noreply, state}
  end
end
