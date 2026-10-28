class Message < ApplicationRecord
  belongs_to :workspace

  scope :unread, -> { where(read_at: nil) }
end
