defmodule BabelWeb.RoomChannel do
  use BabelWeb, :channel

  alias Babel.Repo
  alias BabelWeb.Presence
  alias Babel.Chat

  def join("rooms:" <> room_id, payload, socket) do
    if authorized?(payload) do
      send(self(), "after_join")
      room_id = String.to_integer(room_id)
      messages = Chat.list_messages(room_id)
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
    changeset = message |> Map.put("user_id", user.id) |> Map.put("room_id", socket.assigns.room_id)
    case Chat.create_message(changeset) do
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
    with {:ok, trans_message} <- Chat.translate_and_create_message(message) do
      broadcast_message(socket, trans_message)
    else
      {:error, _} -> :ignore
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
