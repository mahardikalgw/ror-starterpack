class Integration < ApplicationRecord
  belongs_to :workspace

  validates :name, presence: true, uniqueness: { scope: :workspace_id }
  validates :category, presence: true
  validates :rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :profit_cents, :position, numericality: { greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(:position, :id) }
  scope :search, ->(term) {
    next all if term.blank?

    pattern = "%#{sanitize_sql_like(term.to_s.strip)}%"
    where("name LIKE :pattern OR category LIKE :pattern", pattern: pattern)
  }
end
