require "test_helper"

class DashboardNavigationTest < ActiveSupport::TestCase
  setup do
    @workspace = create_workspace
    @payload = Dashboard::Navigation.new(workspace: @workspace).payload
  end

  test "exposes the three reference groups in order" do
    assert_equal [ "General", "Tools", "Support" ], @payload[:groups].map { |group| group[:label] }
  end

  test "only dashboard is routable and active" do
    items = @payload[:groups].flat_map { |group| group[:items] }
    active = items.select { |item| item[:active] }

    assert_equal [ "dashboard" ], active.map { |item| item[:key] }
    assert_equal "/dashboard", active.first[:href]
  end

  # Spec FR-019 lists exactly ten non-dashboard destinations (Message and
  # Automation included), all of which must render as disabled previews.
  test "the ten out-of-scope entries are disabled" do
    items = @payload[:groups].flat_map { |group| group[:items] }

    assert_equal 10, items.count { |item| item[:disabled] }
  end

  test "the message badge comes from unread records" do
    3.times { @workspace.messages.create! }

    payload = Dashboard::Navigation.new(workspace: @workspace).payload
    message = payload[:groups].flat_map { |group| group[:items] }.find { |item| item[:key] == "message" }

    assert_equal "3", message[:badge][:text]
    assert_equal 3, payload[:unread_count]
  end

  test "automation carries the beta tag" do
    automation = @payload[:groups].flat_map { |group| group[:items] }.find { |item| item[:key] == "automation" }

    assert_equal "BETA", automation[:badge][:text]
  end

  test "workspace switcher mirrors the demo workspace" do
    assert_equal "Test Workspace", @payload[:workspace][:name]
    assert_equal "Team", @payload[:workspace][:plan]
  end
end
