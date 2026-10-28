require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @workspace = create_workspace(name: "Dashboard Test Workspace")
    @user = create_user(workspace: @workspace)
    create_metric(workspace: @workspace, date: DEFAULT_START, page_views: 120, revenue_cents: 900,
                  sessions_count: 10, bounced_sessions: 5)
    create_sale(workspace: @workspace, date: DEFAULT_START, region: "usa", amount_cents: 5_000)
    create_snapshot(workspace: @workspace, date: DEFAULT_START, count: 42)
    create_channel_revenue(workspace: @workspace, date: DEFAULT_START, channel: "website", amount_cents: 700)
    create_integration(workspace: @workspace, name: "Stripe", category: "Finance", position: 0)
  end

  test "anonymous request redirects to sign-in" do
    get dashboard_path

    assert_redirected_to new_session_path
  end

  test "anonymous export returns no CSV body" do
    get dashboard_export_path

    assert_redirected_to new_session_path
  end

  test "signed-in request renders the dashboard component with computed props" do
    sign_in_as(@user)
    inertia_get dashboard_path

    assert_response :success

    json = JSON.parse(response.body)
    assert_equal "dashboard/index", json["component"]
    assert_equal 120, json["props"]["kpis"].find { |kpi| kpi["key"] == "page_views" }["value"]
    assert_equal 5_000, json["props"]["sales_overview"]["total"]
    assert_equal 42, json["props"]["subscribers"]["total"]
  end

  test "the dashboard response is not cached" do
    sign_in_as(@user)
    inertia_get dashboard_path

    assert_equal "no-store", response.headers["Cache-Control"]
  end

  test "invalid params fall back instead of erroring" do
    sign_in_as(@user)
    inertia_get dashboard_path, params: { start_date: "oops", granularity: "hourly" }

    assert_response :success
    assert_equal "2023-10-18", JSON.parse(response.body)["props"]["period"]["start_date"]
  end

  test "export returns a CSV attachment with the contract header" do
    sign_in_as(@user)
    get dashboard_export_path

    assert_response :success
    assert_equal "text/csv; charset=utf-8", response.headers["Content-Type"]
    assert_match(/attachment; filename="dashboard-2023-10-18-2023-11-18.csv"/, response.headers["Content-Disposition"])
    assert_match(/Section,Metric,Label,Value/, response.body)
    assert_match(/page_views/, response.body)
  end

  test "export honours the id selection" do
    sign_in_as(@user)
    keep = @workspace.integrations.first
    create_integration(workspace: @workspace, name: "Zapier", category: "CRM", position: 1)

    get dashboard_export_path, params: { ids: [ keep.id ] }

    assert_match(/Stripe/, response.body)
    refute_match(/Zapier/, response.body)
  end

  private
    def inertia_get(path, params: {})
      get path, params: params, headers: {
        "X-Inertia" => "true",
        "X-Inertia-Version" => InertiaRails.configuration.version.to_s
      }
    end
end
