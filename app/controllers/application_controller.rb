class ApplicationController < ActionController::Base
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  inertia_share do
    {
      auth: {
        user: current_user_payload,
        workspace: current_workspace_payload
      },
      flash: { notice: flash[:notice], alert: flash[:alert] }
    }
  end

  private
    def current_user_payload
      user = current_user
      return nil if user.nil?

      {
        id: user.id,
        name: user.name,
        role: user.role,
        email_address: user.email_address
      }
    end

    def current_workspace_payload
      workspace = current_user&.workspace
      return nil if workspace.nil?

      {
        id: workspace.id,
        name: workspace.name,
        plan: workspace.plan,
        currency: workspace.currency
      }
    end
end
