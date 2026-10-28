class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  rate_limit to: 10, within: 3.minutes, only: :create, with: -> {
    redirect_to new_session_path, inertia: { errors: { base: "Too many attempts. Try again later." } }
  }

  def new
    return redirect_to dashboard_path if authenticated?

    render inertia: "sessions/new", props: {
      demo: DemoData.credentials_payload,
      form: { email_address: "" }
    }
  end

  def create
    if (user = User.authenticate_by(params.permit(:email_address, :password).to_h.symbolize_keys))
      start_new_session_for user
      redirect_to after_authentication_url, status: :see_other
    else
      # One generic message that never reveals whether the email exists (FR-012).
      redirect_to new_session_path, inertia: { errors: { base: "Try another email address or password." } }
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
