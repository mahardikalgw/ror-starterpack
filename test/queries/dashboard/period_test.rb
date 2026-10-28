require "test_helper"

class DashboardPeriodTest < ActiveSupport::TestCase
  test "defaults to the documented window and monthly granularity" do
    period = Dashboard::Period.from_params({})

    assert_equal Date.new(2023, 10, 18), period.start_date
    assert_equal Date.new(2023, 11, 18), period.end_date
    assert_equal "monthly", period.granularity
    assert_equal "Oct 18 – Nov 18", period.label
  end

  test "invalid dates fall back to defaults" do
    period = Dashboard::Period.from_params(start_date: "nope", end_date: "also-nope")

    assert_equal Date.new(2023, 10, 18), period.start_date
    assert_equal Date.new(2023, 11, 18), period.end_date
  end

  test "reversed dates fall back to defaults" do
    period = Dashboard::Period.from_params(start_date: "2023-11-18", end_date: "2023-10-18")

    assert_equal Date.new(2023, 10, 18), period.start_date
  end

  test "ranges longer than 366 days fall back to defaults" do
    period = Dashboard::Period.from_params(start_date: "2021-01-01", end_date: "2023-12-31")

    assert_equal Date.new(2023, 10, 18), period.start_date
  end

  test "unknown granularity falls back to monthly" do
    period = Dashboard::Period.from_params(granularity: "daily")

    assert_equal "monthly", period.granularity
  end

  test "comparison range has equal length and ends the day before the start" do
    period = Dashboard::Period.from_params({})
    comparison = period.comparison_range

    assert_equal period.days, comparison.count
    assert_equal period.start_date - 1, comparison.last
    assert_equal period.start_date - period.days, comparison.first
  end

  test "weekly buckets key on the week start" do
    period = Dashboard::Period.from_params(start_date: "2023-10-16", end_date: "2023-10-29", granularity: "weekly")

    assert period.weekly?
    assert_equal 2, period.bucket_keys.size
    assert_equal "2023-10-16", period.bucket_keys.first
    assert_equal "Oct 16", period.bucket_label("2023-10-16")
  end

  test "monthly buckets key on the calendar month" do
    period = Dashboard::Period.from_params({})

    assert_equal [ "2023-10", "2023-11" ], period.bucket_keys
    assert_equal "Oct", period.bucket_label("2023-10")
  end

  test "payload exposes iso dates and the comparison window" do
    payload = Dashboard::Period.from_params({}).payload

    assert_equal "2023-10-18", payload[:start_date]
    assert_equal 32, payload[:days]
    assert_equal "2023-09-16", payload[:comparison][:start_date]
  end
end
