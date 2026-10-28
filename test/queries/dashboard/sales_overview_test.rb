require "test_helper"

class DashboardSalesOverviewTest < ActiveSupport::TestCase
  setup { @workspace = create_workspace }

  test "bucket totals reconcile with the headline total" do
    create_sale(workspace: @workspace, date: DEFAULT_START, region: "usa", amount_cents: 1_000)
    create_sale(workspace: @workspace, date: DEFAULT_START, region: "china", amount_cents: 500)
    create_sale(workspace: @workspace, date: DEFAULT_END, region: "usa", amount_cents: 250)

    payload = build

    assert_equal 1_750, payload[:total]
    assert_equal payload[:total], payload[:buckets].sum { |bucket| bucket[:total] }
  end

  test "missing regions render as zero rather than being omitted" do
    create_sale(workspace: @workspace, date: DEFAULT_START, region: "usa", amount_cents: 1_000)

    bucket = build[:buckets].find { |item| item[:key] == "2023-10" }

    assert_equal 1_000, bucket[:series]["usa"]
    assert_equal 0, bucket[:series]["canada"]
    assert_equal 5, bucket[:series].size
  end

  test "region filters narrow the series" do
    create_sale(workspace: @workspace, date: DEFAULT_START, region: "usa", amount_cents: 1_000)
    create_sale(workspace: @workspace, date: DEFAULT_START, region: "china", amount_cents: 400)

    payload = Dashboard::SalesOverview.new(
      workspace: @workspace, period: default_period,
      filters: Dashboard::Filters.from_params(regions: [ "usa" ])
    ).payload

    assert_equal 1_000, payload[:total]
  end

  test "weekly granularity groups by week start" do
    period = Dashboard::Period.from_params(start_date: "2023-10-16", end_date: "2023-10-29", granularity: "weekly")
    create_sale(workspace: @workspace, date: Date.new(2023, 10, 16), region: "usa", amount_cents: 100)
    create_sale(workspace: @workspace, date: Date.new(2023, 10, 23), region: "usa", amount_cents: 200)

    payload = Dashboard::SalesOverview.new(
      workspace: @workspace, period: period, filters: Dashboard::Filters.from_params({})
    ).payload

    assert_equal 2, payload[:buckets].size
    assert_equal 300, payload[:total]
  end

  private
    def build
      Dashboard::SalesOverview.new(
        workspace: @workspace, period: default_period, filters: Dashboard::Filters.from_params({})
      ).payload
    end
end
