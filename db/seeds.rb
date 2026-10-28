# Deterministic, idempotent demo dataset (US4 / SC-004).
# Re-running this file must never duplicate or corrupt records, so every write is
# keyed on a natural key and re-assigned rather than appended.
require Rails.root.join("lib/demo_data").to_s

workspace = Workspace.find_or_create_by!(name: DemoData::WORKSPACE_NAME) do |record|
  record.plan = DemoData::WORKSPACE_PLAN
  record.currency = DemoData::CURRENCY
end

# --- Demo user -------------------------------------------------------------
demo_user = User.find_or_initialize_by(email_address: DemoData::DEMO_EMAIL)
if demo_user.new_record?
  demo_user.assign_attributes(
    name: DemoData::DEMO_NAME,
    role: DemoData::DEMO_ROLE,
    workspace: workspace,
    password: DemoData::DEMO_PASSWORD
  )
  demo_user.save!
end

# --- Helpers ---------------------------------------------------------------
# Splits an integer total across dates as evenly as possible, putting the
# remainder on the earliest days so the result is reproducible.
distribute = lambda do |dates, total|
  base, remainder = total.divmod(dates.length)
  dates.each_with_index.map { |date, index| [ date, base + (index < remainder ? 1 : 0) ] }
end

seed_dates = (DemoData::SEED_START..DemoData::SEED_END).to_a

# --- Daily metrics ---------------------------------------------------------
# Window A is the default reporting period; window B is its comparison period.
# Targets: page views 12,450 / revenue 36,395 cents / weighted bounce 86.5%.
window_a = (DemoData::DEFAULT_START..DemoData::DEFAULT_END).to_a
window_b = ((DemoData::DEFAULT_START - window_a.length)..(DemoData::DEFAULT_START - 1)).to_a

metrics = seed_dates.index_with do
  { page_views: 200, revenue_cents: 900, sessions_count: 500, bounced_sessions: 400 }
end

assign = lambda do |dates, page_views:, revenue_cents:, sessions_count:, bounced_sessions:|
  distribute.call(dates, page_views).each { |date, value| metrics[date][:page_views] = value }
  distribute.call(dates, revenue_cents).each { |date, value| metrics[date][:revenue_cents] = value }
  distribute.call(dates, sessions_count).each { |date, value| metrics[date][:sessions_count] = value }
  distribute.call(dates, bounced_sessions).each { |date, value| metrics[date][:bounced_sessions] = value }
end

assign.call(window_a, page_views: 12_450, revenue_cents: 36_395, sessions_count: 32_000, bounced_sessions: 27_680)
assign.call(window_b, page_views: 10_751, revenue_cents: 55_144, sessions_count: 32_000, bounced_sessions: 22_283)

metrics.each do |date, values|
  record = workspace.daily_metrics.find_or_initialize_by(recorded_on: date)
  record.assign_attributes(values)
  record.save!
end

# --- Sales records ---------------------------------------------------------
# Monthly gross sales; October and November only carry the days inside the
# default period so the monthly buckets reconcile with the period total.
region_weights = { "china" => 25, "eu" => 20, "usa" => 30, "canada" => 15, "other" => 10 }
monthly_plan = [
  [ Date.new(2023, 9, 1)..Date.new(2023, 9, 30), 210_000 ],
  [ Date.new(2023, 10, 18)..Date.new(2023, 10, 31), 298_820 ],
  [ Date.new(2023, 11, 1)..Date.new(2023, 11, 18), 176_509 ],
  [ Date.new(2023, 12, 1)..Date.new(2023, 12, 31), 400_565 ]
]

monthly_plan.each do |range, month_total|
  dates = range.to_a
  allocated = 0

  region_weights.each_with_index do |(region, weight), index|
    region_total = index == region_weights.size - 1 ? month_total - allocated : (month_total * weight / 100)
    allocated += region_total

    distribute.call(dates, region_total).each do |date, amount|
      record = workspace.sales_records.find_or_initialize_by(recorded_on: date, region: region)
      record.amount_cents = amount
      record.save!
    end
  end
end

# --- Subscriber snapshots --------------------------------------------------
# The seven seeded days sum to the 24,473 period total with a 3,874 peak on
# Tuesday Nov 14; the comparison window totals 749 fewer.
weekly = {
  Date.new(2023, 11, 12) => 3_500,
  Date.new(2023, 11, 13) => 3_650,
  Date.new(2023, 11, 14) => 3_874,
  Date.new(2023, 11, 15) => 3_420,
  Date.new(2023, 11, 16) => 3_510,
  Date.new(2023, 11, 17) => 3_300,
  Date.new(2023, 11, 18) => 3_219
}
comparison_snapshot = { Date.new(2023, 10, 17) => 23_724 }

weekly.merge(comparison_snapshot).each do |date, count|
  record = workspace.subscriber_snapshots.find_or_initialize_by(recorded_on: date)
  record.count = count
  record.save!
end

# --- Channel revenues ------------------------------------------------------
channel_targets = { "website" => 37_482, "mobile_app" => 24_160, "other" => 21_342 }

channel_targets.each do |channel, total|
  distribute.call(window_a, total).each do |date, amount|
    record = workspace.channel_revenues.find_or_initialize_by(recorded_on: date, channel: channel)
    record.amount_cents = amount
    record.save!
  end
end

# --- Integrations ----------------------------------------------------------
integrations = [
  [ "Stripe", "Finance", 40, 65_000 ],
  [ "Zapier", "CRM", 80, 72_050 ],
  [ "Shopify", "Marketplace", 20, 43_225 ],
  [ "Slack", "Communication", 60, 38_400 ],
  [ "Notion", "Productivity", 30, 21_900 ],
  [ "HubSpot", "CRM", 50, 54_600 ]
]

integrations.each_with_index do |(name, category, rate, profit_cents), index|
  record = workspace.integrations.find_or_initialize_by(name: name)
  record.assign_attributes(category: category, rate: rate, profit_cents: profit_cents, position: index)
  record.save!
end

# --- Messages (sidebar badge source) ---------------------------------------
missing = DemoData::UNREAD_MESSAGES - workspace.messages.unread.count
missing.times { workspace.messages.create!(created_at: Time.current) } if missing.positive?

puts "Seeded #{DemoData::WORKSPACE_NAME}: #{workspace.daily_metrics.count} metric days, " \
     "#{workspace.sales_records.count} sales rows, #{workspace.subscriber_snapshots.count} subscriber days, " \
     "#{workspace.channel_revenues.count} channel  #{"rows"}, #{workspace.integrations.count} integrations, " \
     "#{workspace.messages.unread.count} unread messages"
