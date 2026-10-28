module Dashboard
  # Total subscriber count, its comparison delta, and the seven-day bar series
  # with the peak day emphasized (FR-028).
  class Subscribers
    SERIES_LENGTH = 7

    def initialize(workspace:, period:)
      @workspace = workspace
      @period = period
    end

    def payload
      total = scope(period.range).sum(:count)
      previous_total = scope(period.comparison_range).sum(:count)
      series = build_series
      peak = series.max_by { |point| point[:count] }

      {
        total: total,
        delta: Delta.build(current: total, previous: previous_total),
        series: series,
        peak: peak ? { label: peak[:label], count: peak[:count] } : nil
      }
    end

    private
      attr_reader :workspace, :period

      def scope(range)
        workspace.subscriber_snapshots.where(recorded_on: range)
      end

      def build_series
        snapshots = scope(period.range).order(recorded_on: :desc).limit(SERIES_LENGTH).to_a.reverse

        snapshots.map do |snapshot|
          {
            date: snapshot.recorded_on.iso8601,
            label: snapshot.recorded_on.strftime("%a"),
            count: snapshot.count
          }
        end
      end
  end
end
