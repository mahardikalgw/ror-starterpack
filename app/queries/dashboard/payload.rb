module Dashboard
  # Single entry point that assembles every dashboard prop group. The controller
  # and the CSV export both read from here so page and file can never disagree.
  class Payload
    def initialize(workspace:, params:)
      @workspace = workspace
      @period = Period.from_params(params)
      @filters = Filters.from_params(params)
      @show_all = params[:all].to_s == "1"
    end

    attr_reader :workspace, :period, :filters

    def props
      {
        period: period.payload,
        filters: filters.payload,
        kpis: metrics.payload,
        sales_overview: sales_overview.payload,
        subscribers: subscribers.payload,
        distribution: distribution.payload,
        integrations: integrations.payload,
        navigation: navigation.payload,
        meta: { page_title: "Dashboard · Nexus" }
      }
    end

    def integrations_query
      integrations
    end

    private
      def metrics = Metrics.new(workspace: workspace, period: period)
      def sales_overview = SalesOverview.new(workspace: workspace, period: period, filters: filters)
      def subscribers = Subscribers.new(workspace: workspace, period: period)
      def distribution = Distribution.new(workspace: workspace, period: period, filters: filters)
      def integrations = Integrations.new(workspace: workspace, filters: filters, show_all: show_all)
      def navigation = Navigation.new(workspace: workspace)

      def show_all
        @show_all
      end
  end
end
