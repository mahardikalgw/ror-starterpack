class Workspace < ApplicationRecord
  CURRENCIES = %w[USD].freeze

  has_many :users, dependent: :destroy
  has_many :daily_metrics, dependent: :destroy
  has_many :sales_records, dependent: :destroy
  has_many :subscriber_snapshots, dependent: :destroy
  has_many :channel_revenues, dependent: :destroy
  has_many :integrations, dependent: :destroy
  has_many :messages, dependent: :destroy

  validates :name, presence: true, uniqueness: true, length: { maximum: 80 }
  validates :plan, presence: true
  validates :currency, presence: true, inclusion: { in: CURRENCIES }

  def unread_message_count
    messages.unread.count
  end
end
