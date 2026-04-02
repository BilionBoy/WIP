module AuthorizationHandler
  extend ActiveSupport::Concern

  included do
    rescue_from CanCan::AccessDenied, with: :handle_access_denied
  end

  private

  def handle_access_denied(_exception)
    flash[:alert] = I18n.t('messages.not_authorized')
    redirect_back(fallback_location: root_path)
  end
end
