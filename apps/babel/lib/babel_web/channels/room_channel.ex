defmodule BabelWeb.RoomChannel do
  use BabelWeb, :channel
  import Ecto.Query
  import Ecto
  alias Babel.Repo

  def join("rooms:" <> room_id, payload, socket) do
    if authorized?(payload) do
      room_id = String.to_integer(room_id)
      room = Repo.get!(Babel.Chat.Room, room_id)
      messages = Repo.all(from m in assoc(room, :messages),
                            order_by: [asc: m.inserted_at],
                            limit: 200,
                            preload: [:user])
      resp = %{messages: Phoenix.View.render_many(messages, BabelWeb.MessageView, "message.json")}
      {:ok, resp, assign(socket, :room_id, room_id)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in(event, params, socket) do
    user = Repo.get(Babel.Accounts.User, socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  def handle_in("new_message", message, user, socket) do
    changeset = 
      user
      |> build_assoc(:messages, room_id: socket.assigns.room_id)
      |> Babel.Chat.Message.changeset(message)

    case Repo.insert(changeset) do
      {:ok, message} ->
        broadcast_message(socket, message)
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  defp broadcast_message(socket, message) do
    message = Repo.preload(message, :user)
    rendered_message = Phoenix.View.render(BabelWeb.MessageView, "message.json", %{message: message})
    broadcast! socket, "new_message", rendered_message
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
