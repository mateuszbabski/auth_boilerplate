defmodule AuthBoilerplate.AccountTest do
  use AuthBoilerplateWeb.ConnCase, async: true

  import AuthBoilerplate.DataCase
  import AuthBoilerplate.Factory

  alias AuthBoilerplate.Accounts
  alias AuthBoilerplate.{User, UserToken, Auth}

  @correct_credentials %{email: "test@test0.local", password: "test0000"}

  def fixture(:user) do
    insert(:user, email: "test0@test0.local", password: "test0000")
  end

  def create_user(_) do
    %{user: fixture(:user)}
  end

  def create_register_params(_) do
    %{
      register_params: %{
        user: Map.put(params_for(:user, %{}), :password, "test1234")
      }
    }
  end

  describe "get_user_by_email/1" do
    setup [:create_user]

    test "returns the user if email exist", %{user: user} do
      assert user = Auth.get_user_by_email("test0@test0.local")
    end

    test "does not return the user if email doesnt exist", %{user: user} do
      refute Auth.get_user_by_email("bad@email.com")
    end
  end

  describe "get_user_by_email_and_password/2" do
    setup [:create_user]

    test "does not return the user if email is invalid" do
      refute Auth.get_user_by_email_and_password("invalid@email.com", "password")
    end

    test "does not return the user if password is invalid" do
      refute Auth.get_user_by_email_and_password("test0@test0.local", "password")
    end

    test "returns the user if email and password are valid", %{user: user} do
      assert user = Auth.get_user_by_email_and_password("test0@test0.local", "test0000")
    end
  end

  describe "get_user!/1" do
    setup [:create_user]

    test "raise if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
          Auth.get_user!(-1)
      end
    end

    test "returns the user with given id", %{user: user} do
      assert user = Auth.get_user!(user.id)
    end
  end

  describe "register_user/1" do
    setup [:create_user]

    test "requires email and password" do
      assert {:error, changeset} = Auth.register_user(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } == errors_on(changeset)
    end

    test "validates maximum values for email and password" do
      too_long = String.duplicate("iv", 100)
      {:error, changeset} = Auth.register_user(%{email: "#{too_long}@email.com", password: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 50 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness", %{user: user} do
      {:error, changeset} = Auth.register_user(%{email: user.email, password: user.password})
      assert "has already been taken" in errors_on(changeset).email

      {:error, changeset} = Auth.register_user(%{email: String.upcase(user.email), password: user.password})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "register user with hashed password", %{user: user} do
      {:ok, user} = Auth.register_user(@correct_credentials)
      assert user.email == "test@test0.local"
      assert is_binary(user.hash_password)
    end
  end

  #describe "change_user_password/2" do
  #  setup [:create_user]

  #  test "" do

  #  end
  #end

  #describe "update_user_password/3" do
  #  setup [:current_user]

  #  test "" do

  #  end
  #end

  #describe "generate_user_session_token/1" do
  #  setup [:create_user]

  #  test "" do

  #  end
  #end

  #describe "get_user_by_session_token/1" do
  #  setup [:create_user]
    # generate user session token

  #  test "" do

  #  end
  #end

  #describe "delete_session_token/1" do
  #  setup [:create_user]

  #  test "" do

  #  end
  #end

  #describe "deliver_user_reset_password_instructions/2" do
  #  setup [:create_user]

  #  test "" do

  #  end
  #end

  #describe "get_user_by_reset_password_token/1" do
  #  setup [:create_user]

  #  test "" do

  #  end
  #end

  #describe "reset_user_password/2" do
  #  setup [:create_user]

  #  test "" do

  #  end
  #end
end
