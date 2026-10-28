require "test_helper"

class DashboardMetricsTest < ActiveSupport::TestCase
  setup { @workspace = create_workspace }

  test "sums page views and revenue across the period" do
    create_metric(workspace: @workspace, date: DEFAULT_START, page_views: 100, revenue_cents: 500)
    create_metric(workspace: @workspace, date: DEFAULT_END, page_views: 50, revenue_cents: 250)

    kpis = build_metrics

    assert_equal 150, kpis.find { |kpi| kpi[:key] == "page_views" }[:value]
    assert_equal 750, kpis.find { |kpi| kpi[:key] == "total_revenue" }[:value]
  end

  test "bounce rate is weighted by sessions rather than averaged" do
    create_metric(workspace: @workspace, date: DEFAULT_START, sessions_count: 10, bounced_sessions: 5)
    create_metric(workspace: @workspace, date: DEFAULT_END, sessions_count: 90, bounced_sessions: 81)

    kpi = build_metrics.find { |card| card[:key] == "bounce_rate" }

    assert_equal 8_600, kpi[:value]
  end

  test "zero comparison base yields a nil percentage and a flat-or-up direction" do
    create_metric(workspace: @workspace, date: DEFAULT_START, page_views: 100)

    kpi = build_metrics.find { |card| card[:key] == "page_views" }

    assert_nil kpi[:delta][:percentage]
    assert_equal "up", kpi[:delta][:direction]
  end

  test "deltas compare against the preceding equal-length period" do
    create_metric(workspace: @workspace, date: DEFAULT_START, page_views: 150)
    create_metric(workspace: @workspace, date: DEFAULT_START - 1, page_views: 100)

    kpi = build_metrics.find { |card| card[:key] == "page_views" }

    assert_equal "up", kpi[:delta][:direction]
    assert_in_delta 50.0, kpi[:delta][:percentage], 0.1
  end

  test "empty period reports zeros without raising" do
    kpis = build_metrics

    assert_equal 3, kpis.size
    assert(kpis.all? { |kpi| kpi[:value].zero? })
  end

  private
    def build_metrics
      Dashboard::Metrics.new(workspace: @workspace, period: default_period).payload
    end
end
