defmodule BabelWeb.UserView do
  use BabelWeb, :view

  def render("user.json", %{user: user}) do
    %{id: user.id, email: user.email, name: user.name}
  end
end