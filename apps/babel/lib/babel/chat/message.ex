defmodule Babel.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset
  alias Babel.Chat.Message

  schema "messages" do
    field :body, :string
    field :trans_backend, :string
    belongs_to :room, Babel.Chat.Room
    belongs_to :user, Babel.Accounts.User

    timestamps()
  end

  @required [:room_id, :user_id, :body]
  @optional [:trans_backend]
  @doc false
  def changeset(%Message{} = message, attrs) do
    message
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end
end
