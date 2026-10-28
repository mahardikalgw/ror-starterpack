require "test_helper"

class SeedsTest < ActiveSupport::TestCase
  test "seeds are idempotent and hit the documented targets" do
    ActiveRecord::Base.transaction do
      Rails.application.load_seed
      first = counts
      Rails.application.load_seed

      assert_equal first, counts

      workspace = Workspace.find_by!(name: DemoData::WORKSPACE_NAME)
      range = DemoData::DEFAULT_START..DemoData::DEFAULT_END

      assert_equal 12_450, workspace.daily_metrics.where(recorded_on: range).sum(:page_views)
      assert_equal 36_395, workspace.daily_metrics.where(recorded_on: range).sum(:revenue_cents)
      assert_equal 24_473, workspace.subscriber_snapshots.where(recorded_on: range).sum(:count)
      assert_equal 3_874, workspace.subscriber_snapshots.where(recorded_on: range).maximum(:count)
      assert_equal 8, workspace.messages.unread.count
      assert User.exists?(email_address: DemoData::DEMO_EMAIL)

      raise ActiveRecord::Rollback
    end
  end

  private
    def counts
      workspace = Workspace.find_by(name: DemoData::WORKSPACE_NAME)

      {
        workspaces: Workspace.count,
        users: User.count,
        daily_metrics: workspace&.daily_metrics&.count,
        sales_records: workspace&.sales_records&.count,
        subscriber_snapshots: workspace&.subscriber_snapshots&.count,
        channel_revenues: workspace&.channel_revenues&.count,
        integrations: workspace&.integrations&.count,
        messages: workspace&.messages&.count
      }
    end
end
