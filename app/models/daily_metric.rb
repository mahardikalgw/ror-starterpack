class DailyMetric < ApplicationRecord
  belongs_to :workspace

  validates :recorded_on, presence: true, uniqueness: { scope: :workspace_id }
  validates :page_views, :sessions_count, :bounced_sessions, :revenue_cents,
            numericality: { greater_than_or_equal_to: 0 }

  validate :bounced_sessions_within_sessions_count

  private
    def bounced_sessions_within_sessions_count
      return if bounced_sessions.blank? || sessions_count.blank?
      return if bounced_sessions <= sessions_count

      errors.add(:bounced_sessions, "cannot exceed sessions_count")
    end
end
