class SubscriberSnapshot < ApplicationRecord
  belongs_to :workspace

  validates :recorded_on, presence: true, uniqueness: { scope: :workspace_id }
  validates :count, numericality: { greater_than_or_equal_to: 0 }
end
