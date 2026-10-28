require "test_helper"

class DashboardDistributionTest < ActiveSupport::TestCase
  setup { @workspace = create_workspace }

  test "sums channels and returns shares that total one hundred" do
    create_channel_revenue(workspace: @workspace, date: DEFAULT_START, channel: "website", amount_cents: 500)
    create_channel_revenue(workspace: @workspace, date: DEFAULT_START, channel: "mobile_app", amount_cents: 300)
    create_channel_revenue(workspace: @workspace, date: DEFAULT_START, channel: "other", amount_cents: 200)

    payload = build
    amounts = payload[:buckets].index_by { |bucket| bucket[:channel] }

    assert_equal 500, amounts["website"][:amount]
    assert_equal "Website", amounts["website"][:label]
    assert_in_delta 100.0, payload[:buckets].sum { |bucket| bucket[:percentage] }, 0.2
  end

  test "channel filters narrow the donut" do
    create_channel_revenue(workspace: @workspace, date: DEFAULT_START, channel: "website", amount_cents: 500)
    create_channel_revenue(workspace: @workspace, date: DEFAULT_START, channel: "other", amount_cents: 200)

    payload = Dashboard::Distribution.new(
      workspace: @workspace, period: default_period,
      filters: Dashboard::Filters.from_params(channels: [ "website" ])
    ).payload

    assert_equal 500, payload[:buckets].sum { |bucket| bucket[:amount] }
  end

  private
    def build
      Dashboard::Distribution.new(
        workspace: @workspace, period: default_period, filters: Dashboard::Filters.from_params({})
      ).payload
    end
end
