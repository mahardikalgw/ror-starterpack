module Dashboard
  # Integration rows: ordered by position, searched server-side, limited to the
  # reference view unless "See All" is active (FR-030, FR-035).
  class Integrations
    DEFAULT_LIMIT = 3

    def initialize(workspace:, filters:, show_all: false)
      @workspace = workspace
      @filters = filters
      @show_all = show_all
    end

    def payload
      base = workspace.integrations.search(filters.query).ordered
      total_count = base.count
      rows = (show_all ? base : base.limit(DEFAULT_LIMIT)).to_a

      {
        rows: rows.map { |integration| row(integration) },
        count: rows.size,
        total_count: total_count,
        showing_all: show_all,
        empty: rows.empty?
      }
    end

    def rows_for_export(ids: nil)
      base = workspace.integrations.search(filters.query).ordered
      base = base.where(id: Array(ids).map(&:to_i)) if ids.present?
      base.order(:position, :id).to_a
    end

    private
      attr_reader :workspace, :filters
      attr_reader :show_all

      def row(integration)
        {
          id: integration.id,
          name: integration.name,
          category: integration.category,
          rate: integration.rate,
          profit: integration.profit_cents
        }
      end
  end
end
