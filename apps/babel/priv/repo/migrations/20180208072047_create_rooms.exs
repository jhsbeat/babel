defmodule Babel.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :title, :string, null: false
      add :description, :text
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:rooms, [:user_id])
  end
end
