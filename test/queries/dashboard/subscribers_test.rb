require "test_helper"

class DashboardSubscribersTest < ActiveSupport::TestCase
  setup { @workspace = create_workspace }

  test "totals the period and compares with the preceding period" do
    create_snapshot(workspace: @workspace, date: DEFAULT_END, count: 300)
    create_snapshot(workspace: @workspace, date: DEFAULT_START - 1, count: 200)

    payload = Dashboard::Subscribers.new(workspace: @workspace, period: default_period).payload

    assert_equal 300, payload[:total]
    assert_equal "up", payload[:delta][:direction]
    assert_in_delta 50.0, payload[:delta][:percentage], 0.1
  end

  test "series keeps the last seven days and flags the peak" do
    10.times { |index| create_snapshot(workspace: @workspace, date: DEFAULT_END - index, count: 10 + index) }

    payload = Dashboard::Subscribers.new(workspace: @workspace, period: default_period).payload

    assert_equal 7, payload[:series].size
    assert_equal 16, payload[:peak][:count]
  end

  test "empty period yields a nil peak and zero total" do
    payload = Dashboard::Subscribers.new(workspace: @workspace, period: default_period).payload

    assert_equal 0, payload[:total]
    assert_nil payload[:peak]
    assert_empty payload[:series]
  end
end
