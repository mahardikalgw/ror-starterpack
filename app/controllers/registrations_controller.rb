class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  rate_limit to: 10, within: 3.minutes, only: :create, with: -> {
    redirect_to new_registration_path, inertia: { errors: { base: "Too many attempts. Try again later." } }
  }

  def new
    return redirect_to dashboard_path if authenticated?

    render inertia: "registrations/new", props: {
      form: { name: "", email_address: "" }
    }
  end

  def create
    user = User.new(registration_params.merge(workspace: demo_workspace, role: DemoData::DEMO_ROLE))

    if user.save
      start_new_session_for user
      redirect_to after_authentication_url, status: :see_other
    else
      redirect_to new_registration_path, inertia: { errors: field_errors(user) }
    end
  end

  private
    def registration_params
      params.permit(:name, :email_address, :password, :password_confirmation)
    end

    # Field-scoped messages (FR-010). Inertia expects a flat hash of field => message.
    def field_errors(user)
      user.errors.to_hash(true).transform_values(&:first)
    end

    # Self-service sign-up joins the demo workspace, creating it on demand so the
    # flow works before db/seeds.rb has ever run.
    def demo_workspace
      Workspace.find_by(name: DemoData::WORKSPACE_NAME) ||
        Workspace.create!(name: DemoData::WORKSPACE_NAME, plan: DemoData::WORKSPACE_PLAN,
                          currency: DemoData::CURRENCY)
    end
end
