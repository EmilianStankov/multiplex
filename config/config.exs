# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# third-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :multiplex, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:multiplex, :key)
#
# You can also configure a third-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env()}.exs"

# ffmpeg should be available in your PATH configuration
# (or you could change this to a path in your environment)
config :ffmpex, ffmpeg_path: "ffmpeg"
config :ffmpex, ffprobe_path: "ffprobe"

config :multiplex, Multiplex.Endpoint, port: 4000

config :multiplex, Multiplex, base_url: "http://localhost:4000"
config :multiplex, Multiplex, playlists_dir: "D:/Code/elixir/multiplex/playlists"
config :multiplex, Multiplex, segments_dir: "D:/Code/elixir/multiplex/segments"
config :multiplex, Multiplex, uploads_dir: "D:/Code/elixir/multiplex/uploads"

config :multiplex, MultiplexTest, test_dir: "D:/Code/elixir/multiplex/test"
