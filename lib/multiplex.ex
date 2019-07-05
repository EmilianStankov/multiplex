defmodule Multiplex do
  @moduledoc """
  GenServer that handles requests for playlist creation and streaming
  """
  use GenServer

  @doc """
  Get playlist by name

  ## Parameters
    - filename: String
  """
  def get_playlist(session, filename) do
    GenServer.call(session, {:get_playlist, filename})
  end

  @doc """
  Adds a new playlist

  ## Parameters
    - params: Map containig the following keys:
      - file: Plug.Upload containing an .mp3 file
      - segment_duration (optional): Integer that represents the desired duration of the stream segments
  """
  def add_playlist(session, params) do
    with {:ok, config} <- Application.fetch_env(:multiplex, Multiplex) do
      File.mkdir_p(config[:uploads_dir])
      file = "#{config[:uploads_dir]}/#{params["file"].filename}"
      File.cp!(params["file"].path, file)

      case params["segment_duration"] do
        nil -> GenServer.cast(session, {:add_playlist, file})
        x -> GenServer.cast(session, {:add_playlist, file, x})
      end
    end
  end

  @doc """
  Gets a stream segment

  ## Parameters
    - stream: String representing the name of the stream
    - filename: String representing the filename of the desired stream chunk
  """
  def get_stream(session, stream, filename) do
    GenServer.call(session, {:get_stream, stream, filename})
  end

  def start_link(session_id) do
    {:ok, registry} = GenServer.start_link(__MODULE__, :ok)
    Process.register(registry, session_id)
    {:ok, registry}
  end

  def init(_) do
    {:ok, nil}
  end

  @doc """
  GenServer call Handler for Multiplex.get_playlist/1
  """
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

  @doc """
  GenServer cast Handler for Multiplex.get_stream/2
  """
  def handle_call({:get_stream, stream, filename}, _from, state) do
    with {:ok, config} <- Application.fetch_env(:multiplex, Multiplex) do
      case File.exists?("#{config[:segments_dir]}/#{stream}/#{filename}") do
        true ->
          {:reply, %{status: 200, file: "#{config[:segments_dir]}/#{stream}/#{filename}"}, state}

        _ ->
          {:reply, %{status: 404, message: "File not found!"}, state}
      end
    end
  end

  @doc """
  GenServer cast Handler for Multiplex.add_playlist/1 without segment_duration
  """
  def handle_cast({:add_playlist, file}, state) do
    Multiplex.Segment.extract_segments(file)
    |> Multiplex.M3u8.create_playlist()

    {:noreply, state}
  end

  @doc """
  GenServer cast Handler for Multiplex.add_playlist/1 with the optional segment_duration provided
  """
  def handle_cast({:add_playlist, file, segment_duration}, state) do
    Multiplex.Segment.extract_segments(file, ".mp3", segment_duration)
    |> Multiplex.M3u8.create_playlist()

    {:noreply, state}
  end
end
