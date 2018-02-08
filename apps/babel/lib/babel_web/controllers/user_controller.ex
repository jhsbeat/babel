defmodule BabelWeb.UserController do
  use BabelWeb, :controller
  alias Babel.Accounts
  alias Babel.Accounts.User

  def new(conn, _params) do
    cond do
      user = conn.assigns[:current_user] ->
        conn
        |> put_flash(:error, "Already logged in.")
        |> redirect(to: page_path(conn, :index))
      true ->
        changeset = Accounts.change_user(%User{})
        render(conn, "new.html", changeset: changeset)
    end
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> BabelWeb.Auth.login(user)
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: page_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end