module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?, :current_user
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      resume_session.present?
    end

    def current_user
      Current.user
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    # Resolves the signed cookie into a live session, enforcing the documented
    # 30-day inactivity expiry (FR-015): stale rows are pruned, the current row is
    # touched, and an expired row is destroyed with the cookie cleared.
    def find_session_by_cookie
      session_id = cookies.signed[:session_id]
      return if session_id.blank?

      record = Session.find_by(id: session_id)

      if record.nil?
        cookies.delete(:session_id)
        return
      end

      Session.stale.delete_all

      if record.expired?
        record.destroy
        cookies.delete(:session_id)
        return
      end

      record.touch_activity!
      record
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || dashboard_path
    end

    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip,
                            last_active_at: Time.current).tap do |record|
        Current.session = record
        cookies.signed[:session_id] = {
          value: record.id,
          httponly: true,
          same_site: :lax,
          expires: Session::INACTIVITY_LIMIT.from_now
        }
      end
    end

    # Tolerates a nil Current.session so a double sign-out stays idempotent.
    def terminate_session
      Current.session&.destroy
      Current.session = nil
      cookies.delete(:session_id)
    end
end
