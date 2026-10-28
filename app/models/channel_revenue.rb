class ChannelRevenue < ApplicationRecord
  CHANNELS = %w[website mobile_app other].freeze
  CHANNEL_LABELS = { "website" => "Website", "mobile_app" => "Mobile App", "other" => "Other" }.freeze

  belongs_to :workspace

  validates :recorded_on, presence: true, uniqueness: { scope: [ :workspace_id, :channel ] }
  validates :channel, presence: true, inclusion: { in: CHANNELS }
  validates :amount_cents, numericality: { greater_than_or_equal_to: 0 }

  def channel_label
    CHANNEL_LABELS.fetch(channel, channel.to_s.titleize)
  end
end
