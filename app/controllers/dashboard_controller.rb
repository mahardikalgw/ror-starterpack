class DashboardController < ApplicationController
  before_action :prevent_caching

  def index
    render inertia: "dashboard/index", props: payload.props
  end

  def export
    csv = Dashboard::ExportCsv.new(payload: payload, ids: params[:ids]).call
    filename = "dashboard-#{payload.period.start_date}-#{payload.period.end_date}.csv"

    send_data csv,
              type: "text/csv; charset=utf-8",
              disposition: "attachment; filename=\"#{filename}\""
  end

  private
    def payload
      @payload ||= Dashboard::Payload.new(workspace: current_user.workspace, params: params)
    end

    def prevent_caching
      response.headers["Cache-Control"] = "no-store"
    end
end
