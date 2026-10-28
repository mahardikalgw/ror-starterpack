require "test_helper"

class DashboardIntegrationsTest < ActiveSupport::TestCase
  setup { @workspace = create_workspace }

  test "orders by position and limits the reference view to three rows" do
    create_integration(workspace: @workspace, name: "Zapier", category: "CRM", position: 1)
    create_integration(workspace: @workspace, name: "Stripe", category: "Finance", position: 0)
    create_integration(workspace: @workspace, name: "Shopify", category: "Marketplace", position: 2)
    create_integration(workspace: @workspace, name: "Slack", category: "Communication", position: 3)

    payload = build

    assert_equal 3, payload[:count]
    assert_equal 4, payload[:total_count]
    assert_equal "Stripe", payload[:rows].first[:name]
    refute payload[:showing_all]
  end

  test "show_all returns every row" do
    4.times { |index| create_integration(workspace: @workspace, name: "App#{index}", position: index) }

    assert_equal 4, build(show_all: true)[:count]
  end

  test "search matches name or category case-insensitively" do
    create_integration(workspace: @workspace, name: "Stripe", category: "Finance", position: 0)
    create_integration(workspace: @workspace, name: "Zapier", category: "CRM", position: 1)

    payload = Dashboard::Integrations.new(
      workspace: @workspace, filters: Dashboard::Filters.from_params(q: "crm")
    ).payload

    assert_equal 1, payload[:count]
    assert_equal "Zapier", payload[:rows].first[:name]
  end

  test "no matches sets the empty flag" do
    payload = Dashboard::Integrations.new(
      workspace: @workspace, filters: Dashboard::Filters.from_params(q: "nothing-here")
    ).payload

    assert payload[:empty]
    assert_equal 0, payload[:count]
  end

  test "export rows honour the id selection" do
    keep = create_integration(workspace: @workspace, name: "Stripe", position: 0)
    create_integration(workspace: @workspace, name: "Zapier", position: 1)

    query = Dashboard::Integrations.new(workspace: @workspace, filters: Dashboard::Filters.from_params({}))
    rows = query.rows_for_export(ids: [ keep.id ])

    assert_equal [ "Stripe" ], rows.map(&:name)
  end

  private
    def build(show_all: false)
      Dashboard::Integrations.new(
        workspace: @workspace, filters: Dashboard::Filters.from_params({}), show_all: show_all
      ).payload
    end
end
