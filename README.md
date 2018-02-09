# Babel


## Configuration

* apps/babel/config/dev.secret.exs
```elixir
use Mix.Config

# Configure your database
config :babel, Babel.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "your_username",
  password: "your_password",
  database: "babel_dev",
  hostname: "localhost",
  pool_size: 10
```

* apps/trans/config/dev.secret.exs
```elixir
use Mix.Config

config :trans, :papago_nmt, client_id: "your_client_id"
config :trans, :papago_nmt, client_secret: "your_client_secret"
```