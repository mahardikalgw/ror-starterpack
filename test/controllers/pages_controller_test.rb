require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @workspace = create_workspace(name: "Pages Test Workspace")
    @user = create_user(workspace: @workspace)
    create_metric(workspace: @workspace, date: DEFAULT_START, page_views: 99, revenue_cents: 99_999)
  end

  test "anonymous visitors get the public landing page" do
    get root_path

    assert_response :success
    assert_json_component "home"
  end

  test "the anonymous variant offers sign-up and sign-in" do
    get root_path
    body = response.body

    assert_match "Start for free", body
    assert_match "Sign in", body
  end

  test "the signed-in variant points at the dashboard" do
    sign_in_as(@user)

    get root_path

    assert_response :success
    assert_json_component "home"
    assert_match "Open dashboard", response.body
  end

  test "the landing page exposes no workspace analytics" do
    sign_in_as(@user)

    get root_path

    refute_match "99,999", response.body
    refute_match "page_views", response.body
  end

  private
    # Asserts the Inertia component name exactly as the client resolver receives it,
    # which must match a file path relative to app/javascript/pages.
    def assert_json_component(expected)
      inertia_get root_path
      assert_equal expected, JSON.parse(response.body)["component"]
      assert File.exist?(Rails.root.join("app/javascript/pages/#{expected}.tsx")),
             "missing page component file for #{expected}"
    end

    def inertia_get(path)
      get path, headers: { "X-Inertia" => "true", "X-Inertia-Version" => InertiaRails.configuration.version.to_s }
    end
end
