defmodule AuthBoilerplate.Accounts.UserNotifier do
  use Phoenix.Swoosh,
    view: AuthBoilerplateWeb.EmailView

  alias AuthBoilerplate.Mailer

  def deliver_reset_password_instructions(user, token) do
    new()
    |> from("admin@admin.com")
    |> to(user.email)
    |> subject("Password reset link")
    |> render_body("forgot_password.html", %{user: user, token: token})
    |> Mailer.deliver()
  end
end
