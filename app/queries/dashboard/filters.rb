module Dashboard
  # Validates region/channel selections and exposes display metadata (FR-034).
  class Filters
    def self.from_params(params)
      new(regions: Array(params[:regions]), channels: Array(params[:channels]), query: params[:q])
    end

    attr_reader :regions, :channels, :query

    def initialize(regions: [], channels: [], query: nil)
      @regions = sanitize(regions, SalesRecord::REGIONS)
      @channels = sanitize(channels, ChannelRevenue::CHANNELS)
      @query = query.to_s.strip.first(100)
    end

    def region_options
      SalesRecord::REGIONS.map { |value| { value: value, label: SalesRecord::REGION_LABELS.fetch(value) } }
    end

    def channel_options
      ChannelRevenue::CHANNELS.map { |value| { value: value, label: ChannelRevenue::CHANNEL_LABELS.fetch(value) } }
    end

    def active?
      regions.any? || channels.any? || query.present?
    end

    def labels
      labels = []
      regions.each { |value| labels << "Region: #{SalesRecord::REGION_LABELS.fetch(value)}" }
      channels.each { |value| labels << "Channel: #{ChannelRevenue::CHANNEL_LABELS.fetch(value)}" }
      labels << "Search: #{query}" if query.present?
      labels
    end

    def payload
      {
        regions: regions,
        channels: channels,
        region_options: region_options,
        channel_options: channel_options,
        query: query,
        active: active?,
        labels: labels
      }
    end

    private
      # Unknown values are ignored; an empty selection means "all".
      def sanitize(values, allowed)
        Array(values).map { |value| value.to_s }.select { |value| allowed.include?(value) }.uniq
      end
  end
end
