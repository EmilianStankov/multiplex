defmodule Multiplex.M3u8 do
  def create_playlist(folder, segment_duration \\ 4) do
    content = ["#EXTM3U", "#EXT-X-VERSION:3", "#EXT-X-TARGETDURATION:#{segment_duration}"]

    content =
      content ++
        (Path.wildcard("segments/#{folder}/*.ts")
         |> Enum.map(fn segment -> "#EXTINF:#{segment_duration}\n#{segment}" end))

    File.mkdir_p("playlists")
    {:ok, file} = File.open("playlists/#{folder}.m3u8", [:write, :utf8])
    file |> IO.binwrite(Enum.join(content, "\n"))
    File.close(file)
  end
end
