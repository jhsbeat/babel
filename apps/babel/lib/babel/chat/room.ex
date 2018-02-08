defmodule Babel.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset
  alias Babel.Chat.Room

  schema "rooms" do
    field :title, :string
    field :description, :string
    belongs_to :user, Babel.Accounts.User
    has_many :messages, Babel.Chat.Message

    timestamps()
  end

  @required [:user_id, :title]
  @optional [:description]
  @doc false
  def changeset(%Room{} = room, attrs) do
    room
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end
end
