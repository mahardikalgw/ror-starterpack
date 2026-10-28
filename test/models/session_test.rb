require "test_helper"

class SessionTest < ActiveSupport::TestCase
  setup do
    @workspace = create_workspace(name: "Session Test Workspace")
    @user = create_user(workspace: @workspace)
  end

  test "sets last_active_at on create" do
    session = @user.sessions.create!

    assert_not_nil session.last_active_at
    refute session.expired?
  end

  test "expires after thirty days of inactivity" do
    session = @user.sessions.create!
    session.update_column(:last_active_at, 31.days.ago)

    assert session.expired?
  end

  test "touch_activity! refreshes the timestamp" do
    session = @user.sessions.create!
    session.update_column(:last_active_at, 10.days.ago)
    session.touch_activity!

    assert session.reload.last_active_at > 1.minute.ago
  end

  test "stale scope finds only inactive sessions" do
    stale = @user.sessions.create!
    stale.update_column(:last_active_at, 31.days.ago)
    fresh = @user.sessions.create!

    assert_includes Session.stale, stale
    refute_includes Session.stale, fresh
  end
end
