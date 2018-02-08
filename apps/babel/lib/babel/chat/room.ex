defmodule Babel.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset
  alias Babel.Chat.Room


  schema "rooms" do
    field :title, :string
    field :description, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Room{} = room, attrs) do
    room
    |> cast(attrs, [:title, :description])
    |> validate_required([:title, :description])
  end
end
