defmodule BabelWeb.RoomChannelTest do
  use BabelWeb.ChannelCase
  import Babel.TestHelpers
  alias Babel.Repo

  setup do
    user = insert_user(name: "Rebecca")
    room = insert_room(user, %{title: "Testing room"})
    token = Phoenix.Token.sign(@endpoint, "user socket", user.id)
    {:ok, socket} = connect(BabelWeb.UserSocket, %{"token" => token})

    {:ok, socket: socket, user: user, room: room}
  end

  test "join replies with room messages", %{socket: socket, user: user, room: room} do
    for body <- ~w(one two) do
      room
      |> Ecto.build_assoc(:messages, %{body: body, user_id: user.id})
      |> Repo.insert!()
    end

    {:ok, reply, socket} = subscribe_and_join(socket, "rooms:#{room.id}", %{})

    assert socket.assigns.room_id == room.id
    assert %{messages: [%{body: "one"}, %{body: "two"}]} = reply
  end

  test "inserting new messages", %{socket: socket, room: room} do
    {:ok, _, socket} = subscribe_and_join(socket, "rooms:#{room.id}", %{})
    ref = push socket, "new_message", %{body: "the body"}
    assert_reply ref, :ok, %{}
    assert_broadcast "new_message", %{}
  end

  test "new message triggers Trans OTP", %{socket: socket, room: room} do
    {:ok, _, socket} = subscribe_and_join(socket, "rooms:#{room.id}", %{})
    ref = push socket, "new_message", %{body: "한국"}
    assert_reply ref, :ok, %{}
    assert_broadcast "new_message", %{body: "한국"}
    
    # TODO : following assertion must pass after Trans OTP implementation.
    # assert_broadcast "new_message", %{body: "Korea"}
  end
end
