module Dashboard
  # Channel donut and legend amounts (FR-029). Shares are computed here so the
  # client only formats them.
  class Distribution
    def initialize(workspace:, period:, filters:)
      @workspace = workspace
      @period = period
      @filters = filters
    end

    def payload
      sums = scope.group(:channel).sum(:amount_cents)
      total = sums.values.sum

      buckets = ChannelRevenue::CHANNELS.map do |channel|
        amount = sums.fetch(channel, 0).to_i

        {
          channel: channel,
          label: ChannelRevenue::CHANNEL_LABELS.fetch(channel),
          amount: amount,
          percentage: percentage(amount, total)
        }
      end

      { buckets: buckets }
    end

    private
      attr_reader :workspace, :period, :filters

      def scope
        records = workspace.channel_revenues.where(recorded_on: period.range)
        records = records.where(channel: filters.channels) if filters.channels.any?
        records
      end

      def percentage(amount, total)
        return 0.0 if total.zero?

        ((amount * 100.0) / total).round(1)
      end
  end
end
