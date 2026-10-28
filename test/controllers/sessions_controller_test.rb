require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @workspace = create_workspace(name: "Sessions Test Workspace")
    @user = create_user(workspace: @workspace, email_address: "signin@example.com", password: "password123")
  end

  test "new renders the sign-in component for anonymous visitors" do
    get new_session_path

    assert_response :success
    assert_match "sessions/new", response.body
  end

  test "valid credentials start a session and redirect to the dashboard" do
    post session_path, params: { email_address: @user.email_address, password: "password123" }

    assert_redirected_to dashboard_path
    assert_equal 1, @user.sessions.count
  end

  test "wrong credentials show one generic message and create no session" do
    post session_path, params: { email_address: @user.email_address, password: "wrong-password" }

    assert_redirected_to new_session_path
    assert_equal 0, Session.count
  end

  test "unknown email is indistinguishable from a wrong password" do
    post session_path, params: { email_address: "nobody@example.com", password: "password123" }

    assert_redirected_to new_session_path
    follow_redirect!
    assert_match "Try another email address or password.", response.body
  end

  test "anonymous deep link returns to the requested page after sign-in" do
    get dashboard_path
    assert_redirected_to new_session_path

    post session_path, params: { email_address: @user.email_address, password: "password123" }

    assert_redirected_to dashboard_path
  end

  test "sign out destroys the session and is idempotent" do
    sign_in_as(@user)

    delete session_path
    assert_redirected_to new_session_path
    assert_equal 0, Session.count

    delete session_path
    assert_redirected_to new_session_path
  end

  test "signed-in visitors are redirected away from the sign-in page" do
    sign_in_as(@user)

    get new_session_path

    assert_redirected_to dashboard_path
  end
end
