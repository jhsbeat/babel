defmodule BabelWeb.MessageView do
  use BabelWeb, :view

  def render("message.json", %{message: message}) do
    %{
      id: message.id,
      body: message.body,
      user: render_one(message.user, BabelWeb.UserView, "user.json"),
      trans_backend: message.trans_backend
    }
  end
end