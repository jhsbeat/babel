defmodule BabelWeb.RoomChannel do
  use BabelWeb, :channel

  import Ecto.Query
  import Ecto

  alias Babel.Repo
  alias BabelWeb.Presence

  def join("rooms:" <> room_id, payload, socket) do
    if authorized?(payload) do
      send(self(), "after_join")
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

  def handle_info(event, socket) do
    user = Repo.get(Babel.Accounts.User, socket.assigns.user_id)
    handle_info(event, user, socket)
  end

  def handle_info("after_join", user, socket) do
    push socket, "presence_state", Presence.list(socket)  # Push currently joined list.
    # Start to track the user has been joined to the channel.
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{
      display_name: BabelWeb.UserView.display_name(user),
      online_at: :os.system_time(:milli_seconds)
    })
    {:noreply, socket}
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
        Task.start_link(fn -> translate_message_body(message, socket) end)
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

  defp translate_message_body(message, socket) do
    for result <- Trans.translate(message.body, limit: 1, timeout: 10_000) do
      attrs = %{body: result.text, trans_backend: result.backend}
      trans_changeset = 
        Repo.get!(Babel.Accounts.User, socket.assigns.user_id)
          |> build_assoc(:messages, room_id: message.room_id)
          |> Babel.Chat.Message.changeset(attrs)

      case Repo.insert(trans_changeset) do
        {:ok, trans_message} -> broadcast_message(socket, trans_message)
        {:error, changeset} -> :ignore
      end
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
