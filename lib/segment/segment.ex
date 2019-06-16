defmodule Multiplex.Segment do
  import FFmpex
  use FFmpex.Options

  def extract_segments(input_file, segment_time \\ 4) do
    command =
      FFmpex.new_command()
      |> add_input_file(input_file)
      |> add_output_file("segments/#{input_file}.%3d.ts")
      |> add_file_option(option_f("segment"))
      |> add_file_option(%FFmpex.Option{name: "-segment_time", argument: segment_time})

    :ok = execute(command)
  end
end
