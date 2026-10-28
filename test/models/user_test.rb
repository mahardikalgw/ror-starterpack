require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @workspace = create_workspace(name: "User Test Workspace")
  end

  test "normalizes the email address before saving" do
    user = create_user(workspace: @workspace, email_address: "  MiXeD@Example.COM ")

    assert_equal "mixed@example.com", user.email_address
  end

  test "requires a unique email address" do
    create_user(workspace: @workspace, email_address: "dup@example.com")
    duplicate = User.new(name: "Dup", role: "Business", email_address: "DUP@example.com",
                         password: "password123", workspace: @workspace)

    refute duplicate.valid?
    assert duplicate.errors[:email_address].any?
  end

  test "rejects passwords shorter than eight characters" do
    user = User.new(name: "Short", role: "Business", email_address: "s@example.com",
                    password: "short", workspace: @workspace)

    refute user.valid?
    assert user.errors[:password].any?
  end

  test "rejects a missing name and an over-long role" do
    user = User.new(name: "", role: "r" * 41, email_address: "n@example.com",
                    password: "password123", workspace: @workspace)

    refute user.valid?
    assert user.errors[:name].any?
    assert user.errors[:role].any?
  end

  test "requires a workspace" do
    user = User.new(name: "No Workspace", role: "Business", email_address: "w@example.com",
                    password: "password123")

    refute user.valid?
  end

  test "destroys its sessions when removed" do
    user = create_user(workspace: @workspace)
    user.sessions.create!

    assert_difference -> { Session.count }, -1 do
      user.destroy
    end
  end
end
