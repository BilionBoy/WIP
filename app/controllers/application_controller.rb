class ApplicationController < ActionController::Base
  include Pagy::Backend
  include LayoutByUser
  include DevisePermittedParameters
  include AuthorizationHandler

  before_action :authenticate_user!
  before_action :set_current_user
  before_action :set_paper_trail_whodunnit

  private

  def set_current_user
    Current.user = current_user
  end

  def admin_only!
    return if current_user&.admin?

    flash[:alert] = I18n.t('messages.not_authorized')
    redirect_back(fallback_location: root_path)
  end
end
