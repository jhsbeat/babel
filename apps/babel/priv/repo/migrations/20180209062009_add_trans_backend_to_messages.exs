defmodule Babel.Repo.Migrations.AddTransBackendToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :trans_backend, :string, null: true
    end
  end
end
