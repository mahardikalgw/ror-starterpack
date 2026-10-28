# Plain ActiveRecord builders for aggregate assertions (research D13). These are
# deliberately not fixtures: computed aggregates need explicit, readable rows.
module DashboardData
  DEFAULT_START = DemoData::DEFAULT_START
  DEFAULT_END = DemoData::DEFAULT_END

  # Idempotent: a workspace name is unique, and registration itself creates the demo
  # workspace on demand, so a plain create! collides when both happen in one test.
  def create_workspace(name: "Test Workspace", plan: "Team", currency: "USD")
    Workspace.find_or_create_by!(name: name) do |workspace|
      workspace.plan = plan
      workspace.currency = currency
    end
  end

  def create_user(workspace:, email_address: "user@example.com", password: "password123", name: "Test User")
    User.create!(name: name, role: "Business", email_address: email_address,
                 password: password, workspace: workspace)
  end

  def create_metric(workspace:, date:, page_views: 0, revenue_cents: 0, sessions_count: 0, bounced_sessions: 0)
    DailyMetric.create!(workspace: workspace, recorded_on: date, page_views: page_views,
                        revenue_cents: revenue_cents, sessions_count: sessions_count,
                        bounced_sessions: bounced_sessions)
  end

  def create_sale(workspace:, date:, region: "usa", amount_cents: 1_000)
    SalesRecord.create!(workspace: workspace, recorded_on: date, region: region, amount_cents: amount_cents)
  end

  def create_snapshot(workspace:, date:, count: 100)
    SubscriberSnapshot.create!(workspace: workspace, recorded_on: date, count: count)
  end

  def create_channel_revenue(workspace:, date:, channel: "website", amount_cents: 1_000)
    ChannelRevenue.create!(workspace: workspace, recorded_on: date, channel: channel, amount_cents: amount_cents)
  end

  def create_integration(workspace:, name: "Stripe", category: "Finance", rate: 40, profit_cents: 65_000, position: 0)
    Integration.create!(workspace: workspace, name: name, category: category, rate: rate,
                       profit_cents: profit_cents, position: position)
  end

  def default_period
    Dashboard::Period.from_params({})
  end
end

ActiveSupport.on_load(:active_support_test_case) do
  include DashboardData
end
