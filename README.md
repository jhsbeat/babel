# Babel
---
A Toy project to learn Elixir/Phoenix concepts of Content, Channel, OTP, etc.

Elixir/Phoenix를 이용한 동시번역 채팅 애플리케이션 토이 프로젝트 (개발기간 2일)

---
## Demo

![Babel Demo](https://raw.githubusercontent.com/jhsbeat/babel/master/apps/babel/assets/static/images/babel.gif)

---
## Installation

Install Elixir if you don't have:

  * Run `brew install elixir` for Mac users

## Configuration

* apps/babel/config/dev.secret.exs

```elixir
use Mix.Config

# Configure your database
config :babel, Babel.Repo,
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

## Run

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mkdir -p ./priv/repo/migrations && mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd apps/babel/assets && npm install`
  * Start Phoenix endpoint with `cd ../../../ && mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
