module Dashboard
  # The three headline KPI cards (FR-026). Bounce rate is weighted by sessions
  # rather than averaged, and every value is summed from daily_metrics.
  class Metrics
    def initialize(workspace:, period:)
      @workspace = workspace
      @period = period
    end

    def payload
      current = aggregates(period.range)
      previous = aggregates(period.comparison_range)

      [
        card("page_views", "Page Views", "integer", current[:page_views], previous[:page_views]),
        card("total_revenue", "Total Revenue", "currency", current[:revenue_cents], previous[:revenue_cents]),
        card("bounce_rate", "Bounce Rate", "percentage", current[:bounce_rate_bps], previous[:bounce_rate_bps])
      ]
    end

    private
      attr_reader :workspace, :period

      def card(key, label, format, value, previous_value)
        {
          key: key,
          label: label,
          format: format,
          value: value,
          delta: Delta.build(current: value, previous: previous_value)
        }
      end

      def aggregates(range)
        page_views, revenue_cents, bounced, sessions = workspace.daily_metrics
          .where(recorded_on: range)
          .pick(
            Arel.sql("COALESCE(SUM(page_views), 0)"),
            Arel.sql("COALESCE(SUM(revenue_cents), 0)"),
            Arel.sql("COALESCE(SUM(bounced_sessions), 0)"),
            Arel.sql("COALESCE(SUM(sessions_count), 0)")
          )

        {
          page_views: page_views.to_i,
          revenue_cents: revenue_cents.to_i,
          bounce_rate_bps: bounce_rate_bps(bounced.to_i, sessions.to_i)
        }
      end

      def bounce_rate_bps(bounced, sessions)
        return 0 if sessions.zero?

        ((bounced * 10_000.0) / sessions).round
      end
  end
end
