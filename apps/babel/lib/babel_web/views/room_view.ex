defmodule BabelWeb.RoomView do
  use BabelWeb, :view
  alias BabelWeb.RoomView

  def render("index.json", %{rooms: rooms}) do
    %{data: render_many(rooms, RoomView, "room.json")}
  end

  def render("room.json", %{room: room}) do
    %{id: room.id,
      title: room.title,
      description: room.description,
      user_id: room.user_id}
  end
end
