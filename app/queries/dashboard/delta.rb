module Dashboard
  # Shared comparison math. Percentages are one decimal; a zero (or missing)
  # comparison base yields a nil percentage rendered as an em dash, which keeps
  # the payload free of NaN/Infinity.
  module Delta
    module_function

    def build(current:, previous:)
      current = current.to_f
      previous_value = previous.to_f
      difference = current - previous_value

      {
        direction: direction_for(difference),
        percentage: previous_value.zero? ? nil : ((difference * 100.0) / previous_value).round(1),
        amount: difference.round
      }
    end

    def direction_for(difference)
      return "up" if difference.positive?
      return "down" if difference.negative?

      "flat"
    end
  end
end
