require "csv"

module Dashboard
  # Builds the single spreadsheet-friendly export (FR-036) from the same query
  # objects that render the page, with formula-injection protection.
  class ExportCsv
    HEADER = [ "Section", "Metric", "Label", "Value" ].freeze
    DANGEROUS_PREFIXES = [ "=", "+", "-", "@", "\t", "\r" ].freeze

    def initialize(payload:, ids: nil)
      @payload = payload
      @ids = ids
    end

    def call
      CSV.generate do |csv|
        csv << HEADER
        kpi_rows(csv)
        sales_rows(csv)
        subscriber_rows(csv)
        distribution_rows(csv)
        integration_rows(csv)
      end
    end

    private
      attr_reader :payload, :ids

      def props
        @props ||= payload.props
      end

      def kpi_rows(csv)
        props[:kpis].each do |kpi|
          csv << [ "kpi", kpi[:key], kpi[:label], sanitize_value(kpi[:value]) ]
        end
      end

      def sales_rows(csv)
        props[:sales_overview][:buckets].each do |bucket|
          bucket[:series].each do |region, amount|
            csv << [ "sales", region, bucket[:label], sanitize_value(amount) ]
          end
        end
      end

      def subscriber_rows(csv)
        props[:subscribers][:series].each do |point|
          csv << [ "subscribers", point[:date], point[:label], sanitize_value(point[:count]) ]
        end
      end

      def distribution_rows(csv)
        props[:distribution][:buckets].each do |bucket|
          csv << [ "distribution", bucket[:channel], bucket[:label], sanitize_value(bucket[:amount]) ]
        end
      end

      def integration_rows(csv)
        payload.integrations_query.rows_for_export(ids: ids).each do |integration|
          rows = [ [ "name", integration.name ], [ "category", integration.category ],
                   [ "rate", integration.rate ], [ "profit", integration.profit_cents ] ]

          rows.each { |metric, value| csv << [ "integrations", metric, integration.name, sanitize_value(value) ] }
        end
      end

      def sanitize_value(value)
        text = value.to_s
        return "'#{text}" if DANGEROUS_PREFIXES.include?(text[0])

        text
      end
  end
end
