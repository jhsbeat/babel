defmodule BabelWeb.UserView do
  use BabelWeb, :view
  alias Babel.Accounts.User

  def display_name(%User{email: email, name: name}) do
    name || (email |> String.split("@") |> Enum.at(0))
  end

  def render("user.json", %{user: user}) do
    %{id: user.id, email: user.email, name: user.name, display_name: display_name(user)}
  end
end