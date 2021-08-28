# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :ex_conductor,
  ecto_repos: [ExConductor.Repo]

# Configures the endpoint
config :ex_conductor, ExConductorWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "DQyuZKLhR3U8J6hEY0BcxxHMc5Wpx8hIL6KGtnvb3BpCi3FcAx6XnAvC1j44avo/",
  render_errors: [view: ExConductorWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ExConductor.PubSub,
  live_view: [signing_salt: "+VYL02+v"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ex_conductor, :png_generator_fn, &ExConductor.Lilypond.generate_png/1

config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
