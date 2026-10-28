class Session < ApplicationRecord
  INACTIVITY_LIMIT = 30.days

  belongs_to :user

  before_validation :set_last_active_at, on: :create

  validates :last_active_at, presence: true

  scope :stale, -> { where(last_active_at: ...INACTIVITY_LIMIT.ago) }

  def expired?
    last_active_at.nil? || last_active_at < INACTIVITY_LIMIT.ago
  end

  def touch_activity!
    update_column(:last_active_at, Time.current)
  end

  private
    def set_last_active_at
      self.last_active_at ||= Time.current
    end
end
