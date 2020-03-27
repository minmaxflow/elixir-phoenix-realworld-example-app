# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :conduit,
  ecto_repos: [Conduit.Repo]

# config migration
config :conduit, Conduit.Repo,
  migration_timestamps: [type: :utc_datetime, inserted_at: :created_at],
  migration_primary_key: [type: :binary_id]

# Configures the endpoint
config :conduit, ConduitWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "fymHyDGtZZAtgt0YfZCES/py1bPHo2m9NP8SpbbGujp5AdWbl/sdO9vWhFX6KiG4",
  render_errors: [view: ConduitWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Conduit.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :conduit, ConduitWeb.Guardian,
  issuer: "conduit",
  secret_key: "xCAyy591Kr8KCU2XvERi031fs8wyTSVZxGKs4kYsbhBaAHu42wPSc/cYSqMdumQF"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
