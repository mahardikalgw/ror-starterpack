require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @workspace = create_workspace(name: DemoData::WORKSPACE_NAME)
  end

  test "new renders the registration component" do
    get new_registration_path

    assert_response :success
    assert_match "registrations/new", response.body
  end

  test "valid details create the account and sign the visitor in" do
    assert_difference -> { User.count }, 1 do
      post registration_path, params: {
        name: "New Person", email_address: "New.Person@Example.com",
        password: "password123", password_confirmation: "password123"
      }
    end

    assert_redirected_to dashboard_path
    user = User.find_by(email_address: "new.person@example.com")
    assert_equal @workspace, user.workspace
    assert_equal 1, user.sessions.count
  end

  test "duplicate email is rejected without creating a second account" do
    create_user(workspace: @workspace, email_address: "taken@example.com")

    assert_no_difference -> { User.count } do
      post registration_path, params: {
        name: "Other", email_address: "taken@example.com",
        password: "password123", password_confirmation: "password123"
      }
    end

    assert_redirected_to new_registration_path
  end

  test "short password is rejected" do
    assert_no_difference -> { User.count } do
      post registration_path, params: {
        name: "Short", email_address: "short@example.com",
        password: "short", password_confirmation: "short"
      }
    end

    assert_redirected_to new_registration_path
  end

  test "mismatched confirmation is rejected" do
    assert_no_difference -> { User.count } do
      post registration_path, params: {
        name: "Mismatch", email_address: "mismatch@example.com",
        password: "password123", password_confirmation: "password124"
      }
    end

    assert_redirected_to new_registration_path
  end

  test "signed-in visitors are redirected away from the registration page" do
    user = create_user(workspace: @workspace)
    sign_in_as(user)

    get new_registration_path

    assert_redirected_to dashboard_path
  end
end
