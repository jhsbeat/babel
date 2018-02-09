use Mix.Config

import_config "test.secret.exs"

config :trans, :papago_nmt, http_client: InfoSys.Test.HTTPClient