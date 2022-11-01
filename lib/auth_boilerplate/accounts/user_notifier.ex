defmodule AuthBoilerplate.Accounts.UserNotifier do
  use Phoenix.Swoosh,
    view: AuthBoilerplateWeb.EmailView

  import Swoosh.Email

  alias AuthBoilerplate.Mailer

  @doc """
    Creates email with reset password link
  """
  def create_forgot_password_email(user, token) do
    url = "/auth/reset_password?token=#{token}"

    new()
    |> to(user.email)
    |> from({"AuthBoilerplate", "admin@AuthBoilerplate.com"})
    |> subject("AuthBoilerplate - Reset Password")
    |> render_body("forgot_password.html", %{email: user.email, url: url, token: token})
  end

  @doc """
    Delivers the email using application mailer
  """
  def send_forgot_password_email(user, token) do
    user
    |> create_forgot_password_email(token)
    |> Mailer.deliver()
  end
end
