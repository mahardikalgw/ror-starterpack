require "test_helper"

class DashboardPayloadTest < ActiveSupport::TestCase
  setup do
    @workspace = create_workspace
    create_metric(workspace: @workspace, date: DEFAULT_START, page_views: 10, sessions_count: 10, bounced_sessions: 1)
    create_sale(workspace: @workspace, date: DEFAULT_START)
    create_snapshot(workspace: @workspace, date: DEFAULT_START)
    create_channel_revenue(workspace: @workspace, date: DEFAULT_START)
    create_integration(workspace: @workspace)
  end

  test "envelope keys match the dashboard contract" do
    props = build

    expected = %i[ period filters kpis sales_overview subscribers distribution integrations navigation meta ]
    assert_equal expected.sort, props.keys.sort
  end

  test "kpis are ordered page views, revenue, bounce rate" do
    assert_equal %w[page_views total_revenue bounce_rate], build[:kpis].map { |kpi| kpi[:key] }
  end

  test "no value in the payload is NaN or Infinity" do
    assert_no_match(/NaN|Infinity/, build.to_json)
  end

  test "metrics never emit preformatted currency strings" do
    assert_equal build[:kpis].find { |kpi| kpi[:key] == "total_revenue" }[:format], "currency"
    refute_match(/_cents/, build[:kpis].map { |kpi| kpi[:key] }.join)
  end

  test "invalid params never raise and fall back to defaults" do
    props = Dashboard::Payload.new(
      workspace: @workspace,
      params: { start_date: "bad", end_date: "worse", granularity: "hourly", regions: [ "nope" ] }
    ).props

    assert_equal "2023-10-18", props[:period][:start_date]
    assert_equal "monthly", props[:period][:granularity]
    assert_empty props[:filters][:regions]
  end

  private
    def build
      Dashboard::Payload.new(workspace: @workspace, params: {}).props
    end
end
