##
# Single source of demo constants shared by db/seeds.rb, the sign-in page hint,
# and the test helpers. Keeping them here prevents the credentials and date
# anchors from drifting between the seeder and the UI.
module DemoData
  WORKSPACE_NAME = "Marketing"
  WORKSPACE_PLAN = "Team"
  CURRENCY = "USD"

  DEMO_NAME = "Young Alaska"
  DEMO_EMAIL = "demo@nexus.io"
  DEMO_PASSWORD = "demo1234"
  DEMO_ROLE = "Business"

  SEED_START = Date.new(2023, 9, 1)
  SEED_END = Date.new(2023, 12, 31)
  DEFAULT_START = Date.new(2023, 10, 18)
  DEFAULT_END = Date.new(2023, 11, 18)

  UNREAD_MESSAGES = 8

  def self.credentials_visible?
    ENV["SHOW_DEMO_CREDENTIALS"] != "false"
  end

  def self.demo_user
    User.find_by(email_address: DEMO_EMAIL)
  end

  def self.credentials_payload
    return nil unless credentials_visible? && demo_user.present?

    {
      email_address: DEMO_EMAIL,
      password: DEMO_PASSWORD,
      note: "Demo credentials for this template only."
    }
  end
end
