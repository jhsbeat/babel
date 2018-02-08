defmodule Babel.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Babel.Accounts.User


  schema "users" do
    field :email, :string
    field :is_admin, :boolean, default: false
    field :name, :string
    field :password_hash, :string

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password_hash, :name, :is_admin])
    |> validate_required([:email, :password_hash, :name, :is_admin])
  end
end
