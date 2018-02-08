defmodule Babel.TestHelpers do
  alias Babel.Repo
  alias Babel.Accounts.User
  alias Babel.Chat

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
      email: "testuser_#{Base.encode16(:crypto.strong_rand_bytes(8))}@test.com",
      name: "Some User",
      password: "supersecret",
      password_confirmation: "supersecret"
    }, attrs)

    %User{}
    |> User.registration_changeset(changes)
    |> Repo.insert!()
  end

  def insert_room(user, attrs \\ %{}) do
    {:ok, room} = Chat.create_room(Map.put(attrs, :user_id, user.id))
    room
  end
end