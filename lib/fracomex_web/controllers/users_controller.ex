defmodule FracomexWeb.UsersController do
  use FracomexWeb, :controller
  alias FracomexWeb.Router.Helpers, as: Routes
  alias Fracomex.Accounts
  alias Fracomex.Accounts.{User, Country, City}
  alias Fracomex.Token
  alias Fracomex.UserEmail

  #page mon compte
  def my_account(conn, _params) do
    cond do
      is_nil(get_session(conn, :user_id)) ->
        redirect(conn, to: "/signin")
      true ->
        render(conn, "my_account.html", layout: {FracomexWeb.LayoutView, "layout.html"})
    end
  end

  #page adresse
  def my_address(conn, _params) do
    render(conn, "my_address.html", layout: {FracomexWeb.LayoutView, "layout.html"})
  end

  def index(conn, _params) do
    render(conn, "signin.html", layout: {FracomexWeb.LayoutView, "layout.html"})
  end

  # Page de connexion
  def signin(conn, _params) do
    changeset = Accounts.change_user(%User{})
    cond do
      is_nil(get_session(conn, :user_id)) ->
        render(conn, "signin.html", changeset: changeset, layout: {FracomexWeb.LayoutView, "layout.html"})
      true ->
        # IO.inspect(conn)
        redirect(conn, to: "/my_account")
    end
  end

  # Page d'inscription
  def signup(conn, _params) do

    # Génération du changeset neutre pour User et liste des pays et villes sur le formulaire
    changeset = Accounts.change_user(%User{})
    countries = Accounts.list_countries
                |> Enum.map(fn country -> [key: country.name, value: country.id] end)
    cities = Accounts.list_cities
                |> Enum.sort_by(&(&1.name))
                |> Enum.map(fn city -> [key: city.name, value: city.id] end)

    render(conn, "signup.html", changeset: changeset, countries: countries, cities: cities, layout: {FracomexWeb.LayoutView, "layout.html"})
  end

  # Validation de formulaire d'inscription avec envoi de mail de confirmation
  def submit_signup(conn, %{"user" => user_params}) do
    # IO.inspect user_params

    countries = Accounts.list_countries
                |> Enum.map(fn country -> [key: country.name, value: country.id] end)
    cities = Accounts.list_cities
                |> Enum.sort_by(&(&1.name))
                |> Enum.map(fn city -> [key: city.name, value: city.id] end)

    case Accounts.create_user(user_params) do
      {:ok, user} ->
        token = Token.generate_new_account_token(user.id)
        check_mail_url = "#{FracomexWeb.Endpoint.url()}#{Routes.users_path(conn, :check_signup_mail, token: token)}"
        UserEmail.send_check_signup_mail(check_mail_url, user.mail_address)
        conn
        |> render("signup_mail_sent.html", layout: {FracomexWeb.LayoutView, "layout.html"})
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "signup.html", changeset: changeset, countries: countries, cities: cities, layout: {FracomexWeb.LayoutView, "layout.html"})
    end
  end

  # Validation de formulaire de connexion
  def submit_signin(conn, %{"user" => user_params}) do
    # IO.inspect(user_params)
    case Accounts.signin_user(user_params) do
      {:error, changeset} ->
        # IO.inspect(changeset)
        render(conn, "signin.html", changeset: changeset, layout: {FracomexWeb.LayoutView, "layout.html"})
      _ ->
        id = Accounts.get_user_by_mail_address!(user_params["mail_address"]).id
        conn
        |> put_session(:user_id, id)
        |>redirect(to: "/product")
    end
  end

  # Redirection après la vérification de l'adresse email de l'utilisateur récemment inscrit
  def check_signup_mail(conn, %{"token" => token}) do
    # IO.inspect(token)

    with  {:ok, user_id} <- Fracomex.Token.verify_new_account_token(token) do
      # IO.inspect(user_id)
      Accounts.validate_user(Accounts.get_user!(user_id))
      render(conn, "valid_signup_token.html", layout: {FracomexWeb.LayoutView, "layout.html"})
    else
      _ -> render(conn, "invalid_signup_token.html", layout: {FracomexWeb.LayoutView, "layout.html"})
    end

  end

  # Formulaire pour mot de passe oublié
  def forgot_password(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "forgot_password.html", changeset: changeset, layout: {FracomexWeb.LayoutView, "layout.html"})
  end

  # Envoi de l'adresse mail de mot de passe oublié de l'utilisateur
  def submit_forgotten_password(conn, %{"user" => user_params}) do

    case Accounts.forgot_password(user_params) do
      {:error, changeset} ->
        # IO.inspect(changeset)
        render(conn, "forgot_password.html", changeset: changeset, layout: {FracomexWeb.LayoutView, "layout.html"})
      _ ->
        user = Accounts.get_user_by_mail_address!(user_params["mail_address"])
        token = Token.generate_new_account_token(user.id)
        forgot_password_mail_url = "#{FracomexWeb.Endpoint.url()}#{Routes.users_path(conn, :check_forgotten_password_mail, token: token)}"
        UserEmail.send_forgotten_password_mail(forgot_password_mail_url, user.mail_address)
        render(conn, "forgot_password_mail_sent.html", layout: {FracomexWeb.LayoutView, "layout.html"})
    end

  end

  # LIEN VERS LE FORMULAIRE DE MODIFICATION DU MOT DE PASSE OUBLIÉ
  def check_forgotten_password_mail(conn, %{"token" => token}) do
    with  {:ok, user_id} <- Fracomex.Token.verify_new_account_token(token) do
      # IO.inspect(user_id)
      changeset = Accounts.change_user(%User{})
      render(conn, "update_forgotten_password.html", changeset: changeset, user_id: user_id,layout: {FracomexWeb.LayoutView, "layout.html"})
    else
      _ -> render(conn, "invalid_forgotten_password_token.html", layout: {FracomexWeb.LayoutView, "layout.html"})
    end
  end

  # VALIDATION DU FORMULAIRE DE MODIFICATION DE MOT DE PASSE OUBLIÉ
  def submit_new_password_forgotten(conn, %{"id" => id, "user" => user_params}) do
    {user_id, _} = Integer.parse(id)

    user = Accounts.get_user!(user_id)
    case Accounts.update_new_password_forgotten_user(user, user_params) do
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "update_forgotten_password.html", changeset: changeset, user_id: user_id,layout: {FracomexWeb.LayoutView, "layout.html"})
      _ ->
        render(conn, "valid_forgotten_password_token.html", layout: {FracomexWeb.LayoutView, "layout.html"})
    end
  end

  # FORMULAIRE DE RENVOI DE CONFIRMATION DU MAIL
  def resend_confirmation_mail(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "resend_confirmation_mail.html", changeset: changeset,layout: {FracomexWeb.LayoutView, "layout.html"})
  end

  def submit_resend_confirmation_mail(conn, %{"user" => user_params}) do

    case Accounts.resend_confirmation_mail(user_params) do
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "resend_confirmation_mail.html", changeset: changeset,layout: {FracomexWeb.LayoutView, "layout.html"})
      _ ->
        user = Accounts.get_user_by_mail_address!(user_params["mail_address"])
        token = Token.generate_new_account_token(user.id)
        check_mail_url = "#{FracomexWeb.Endpoint.url()}#{Routes.users_path(conn, :check_signup_mail, token: token)}"
        UserEmail.send_check_signup_mail(check_mail_url, user.mail_address)
        render(conn, "signup_mail_sent.html", layout: {FracomexWeb.LayoutView, "layout.html"})
      end

  end

end
