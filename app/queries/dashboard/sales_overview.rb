module Dashboard
  # Stacked regional sales series. One SQL grouping, bucketed in Ruby so the keys
  # always align with the period's bucket list (research D7/D9).
  class SalesOverview
    def initialize(workspace:, period:, filters:)
      @workspace = workspace
      @period = period
      @filters = filters
    end

    def payload
      buckets = period.bucket_keys.map do |key|
        { key: key, label: period.bucket_label(key), series: empty_series, total: 0 }
      end
      index = buckets.index_by { |bucket| bucket[:key] }

      grouped_sums.each do |(recorded_on, region), cents|
        bucket = index[period.bucket_key(recorded_on)]
        next if bucket.nil?

        bucket[:series][region] = bucket[:series].fetch(region, 0) + cents.to_i
        bucket[:total] += cents.to_i
      end

      total = buckets.sum { |bucket| bucket[:total] }

      {
        total: total,
        delta: Delta.build(current: total, previous: comparison_total),
        series_meta: series_meta,
        buckets: buckets
      }
    end

    private
      attr_reader :workspace, :period, :filters

      def scope(range)
        records = workspace.sales_records.where(recorded_on: range)
        records = records.where(region: filters.regions) if filters.regions.any?
        records
      end

      def grouped_sums
        scope(period.range).group(:recorded_on, :region).sum(:amount_cents)
      end

      def comparison_total
        scope(period.comparison_range).sum(:amount_cents)
      end

      def series_meta
        SalesRecord::REGIONS.map { |region| { key: region, label: SalesRecord::REGION_LABELS.fetch(region) } }
      end

      def empty_series
        SalesRecord::REGIONS.index_with(0)
      end
  end
end
