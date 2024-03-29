defmodule Multiplex.M3u8 do
  @moduledoc """
  Creates an .m3u8 playlist file for a folder containing stream chunks
  """

  @doc """
  Create playlist for a given folder of stream segments.
  The playlist name is the same as the folder name.

  ## Parameters
    - folder: String - path of the folder containing stream segments
    - segment_duration: Integer - segment duration in seconds (default: 4)
  """
  def create_playlist(folder, segment_duration \\ 4) do
    content = ["#EXTM3U", "#EXT-X-VERSION:3", "#EXT-X-TARGETDURATION:#{segment_duration}"]

    with {:ok, config} <- Application.fetch_env(:multiplex, Multiplex) do
      content =
        content ++
          (Path.wildcard("#{config[:segments_dir]}/#{folder}/*.ts")
           |> Enum.map(fn segment -> Path.relative_to(segment, config[:segments_dir]) end)
           |> Enum.map(fn segment -> "#{config[:base_url]}/stream/#{segment}" end)
           |> Enum.map(fn segment -> "#EXTINF:#{segment_duration}\n#{segment}" end))

      content = content ++ ["#EXT-X-ENDLIST"]

      File.mkdir_p(config[:playlists_dir])
      {:ok, file} = File.open("#{config[:playlists_dir]}/#{folder}.m3u8", [:write, :utf8])
      file |> IO.binwrite(Enum.join(content, "\n"))
      File.close(file)
    end
  end
end
