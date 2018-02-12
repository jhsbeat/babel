defmodule Babel.Chat do
  @moduledoc """
  The Chat context.
  """

  import Ecto.Query, warn: false
  import Ecto
  alias Babel.Repo

  alias Babel.Chat.Room
  alias Babel.Chat.Message

  @doc """
  Returns the list of rooms.

  ## Examples

      iex> list_rooms()
      [%Room{}, ...]

  """
  def list_rooms do
    Repo.all(Room)
  end

  @doc """
  Gets a single room.

  Raises `Ecto.NoResultsError` if the Room does not exist.

  ## Examples

      iex> get_room!(123)
      %Room{}

      iex> get_room!(456)
      ** (Ecto.NoResultsError)

  """
  def get_room!(id), do: Repo.get!(Room, id)

  @doc """
  Creates a room.

  ## Examples

      iex> create_room(%{field: value})
      {:ok, %Room{}}

      iex> create_room(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_room(attrs \\ %{}) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a room.

  ## Examples

      iex> update_room(room, %{field: new_value})
      {:ok, %Room{}}

      iex> update_room(room, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Room.

  ## Examples

      iex> delete_room(room)
      {:ok, %Room{}}

      iex> delete_room(room)
      {:error, %Ecto.Changeset{}}

  """
  def delete_room(%Room{} = room) do
    Repo.delete(room)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking room changes.

  ## Examples

      iex> change_room(room)
      %Ecto.Changeset{source: %Room{}}

  """
  def change_room(%Room{} = room) do
    Room.changeset(room, %{})
  end

  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  def list_messages(room_id) do
    room = Repo.get!(Room, room_id)
    Repo.all(from m in assoc(room, :messages),
            order_by: [asc: m.inserted_at],
            limit: 200,
            preload: [:user])
  end

  def translate_and_create_message(message, opts \\ %{}) do
    result = Trans.translate(message.body, limit: opts[:limit] || 1, timeout: opts[:timeout] || 10_000)
             |> Enum.at(0)

    attrs = %{body: result.text, trans_backend: result.backend}
      Repo.get!(Babel.Accounts.User, message.user_id)
        |> build_assoc(:messages, room_id: message.room_id)
        |> Message.changeset(attrs)
        |> Repo.insert
  end
end
