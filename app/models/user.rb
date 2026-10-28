class User < ApplicationRecord
  has_secure_password

  belongs_to :workspace
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(email) { email.to_s.strip.downcase }

  validates :name, presence: true, length: { maximum: 80 }
  validates :role, presence: true, length: { maximum: 40 }
  validates :email_address, presence: true, length: { maximum: 254 },
                            uniqueness: { case_sensitive: false },
                            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true
end
