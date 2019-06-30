defmodule Multiplex.Segment do
  import FFmpex
  use FFmpex.Options

  def extract_segments(input_file, file_ext \\ ".mp3", segment_time \\ 4) do
    with {:ok, config} <- Application.fetch_env(:multiplex, Multiplex) do
      file = "#{config[:uploads_dir]}/#{input_file.filename}"
      File.cp!(input_file.path, file)

      basename = Path.basename(file, file_ext)
      File.mkdir_p("#{config[:segments_dir]}/#{basename}")

      command =
        FFmpex.new_command()
        |> add_input_file(file)
        |> add_output_file("#{config[:segments_dir]}/#{basename}/#{basename}.%3d.ts")
        |> add_file_option(option_f("segment"))
        |> add_file_option(%FFmpex.Option{name: "-segment_time", argument: segment_time})

      :ok = execute(command)
      basename
    end
  end
end
