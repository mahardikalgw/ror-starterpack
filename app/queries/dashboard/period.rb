module Dashboard
  # Parses and validates the reporting window (FR-025, FR-032, FR-033).
  # Invalid or out-of-range input always falls back to the documented defaults so
  # the server never returns a 422 for filter input.
  class Period
    MAX_DAYS = 366
    GRANULARITIES = %w[monthly weekly].freeze

    attr_reader :start_date, :end_date, :granularity

    def self.from_params(params)
      new(start_date: params[:start_date], end_date: params[:end_date], granularity: params[:granularity])
    end

    def initialize(start_date:, end_date:, granularity:)
      parsed_start = parse_date(start_date)
      parsed_end = parse_date(end_date)

      unless valid_range?(parsed_start, parsed_end)
        parsed_start = DemoData::DEFAULT_START
        parsed_end = DemoData::DEFAULT_END
      end

      @start_date = parsed_start
      @end_date = parsed_end
      @granularity = GRANULARITIES.include?(granularity.to_s) ? granularity.to_s : "monthly"
    end

    def range
      start_date..end_date
    end

    def days
      (end_date - start_date).to_i + 1
    end

    def weekly?
      granularity == "weekly"
    end

    def bucket
      weekly? ? :week : :month
    end

    # Equal length to the selected period, ending the day before it starts.
    def comparison_range
      (start_date - days)..(start_date - 1)
    end

    def label
      "#{format_date(start_date)} – #{format_date(end_date)}"
    end

    def payload
      {
        start_date: start_date.iso8601,
        end_date: end_date.iso8601,
        label: label,
        granularity: granularity,
        comparison: {
          start_date: comparison_range.first.iso8601,
          end_date: comparison_range.last.iso8601
        },
        days: days
      }
    end

    # Bucket identity: ISO date of the week start (weekly) or "YYYY-MM" (monthly).
    # Keys are computed in Ruby from the period dates, so the same helper aligns
    # SQL-grouped rows with the bucket list without relying on SQLite date formats.
    def bucket_key(date)
      weekly? ? date.beginning_of_week.iso8601 : date.strftime("%Y-%m")
    end

    def bucket_label(key)
      if weekly?
        Date.iso8601(key).strftime("%b %-d")
      else
        Date.strptime("#{key}-01", "%Y-%m-%d").strftime("%b")
      end
    end

    def bucket_keys
      (start_date..end_date).map { |date| bucket_key(date) }.uniq
    end

    private
      def parse_date(value)
        return nil if value.blank?

        Date.iso8601(value.to_s)
      rescue Date::Error, ArgumentError
        nil
      end

      def valid_range?(parsed_start, parsed_end)
        return false if parsed_start.nil? || parsed_end.nil?
        return false if parsed_start > parsed_end

        (parsed_end - parsed_start).to_i + 1 <= MAX_DAYS
      end

      def format_date(date)
        date.strftime("%b %-d")
      end
  end
end
