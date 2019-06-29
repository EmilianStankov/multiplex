defmodule Multiplex.Segment do
  import FFmpex
  use FFmpex.Options

  def extract_segments(input_file, file_ext \\ ".mp3", segment_time \\ 4) do
    basename = Path.basename(input_file, file_ext)

    File.mkdir_p("segments/#{basename}")

    command =
      FFmpex.new_command()
      |> add_input_file(input_file)
      |> add_output_file("segments/#{basename}/#{basename}.%3d.ts")
      |> add_file_option(option_f("segment"))
      |> add_file_option(%FFmpex.Option{name: "-segment_time", argument: segment_time})

    :ok = execute(command)
  end
end