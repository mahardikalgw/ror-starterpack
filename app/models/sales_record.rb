class SalesRecord < ApplicationRecord
  REGIONS = %w[china eu usa canada other].freeze
  REGION_LABELS = { "china" => "China", "eu" => "UE", "usa" => "USA", "canada" => "Canada", "other" => "Other" }.freeze

  belongs_to :workspace

  validates :recorded_on, presence: true, uniqueness: { scope: [ :workspace_id, :region ] }
  validates :region, presence: true, inclusion: { in: REGIONS }
  validates :amount_cents, numericality: { greater_than_or_equal_to: 0 }

  def region_label
    REGION_LABELS.fetch(region, region.to_s.titleize)
  end
end
