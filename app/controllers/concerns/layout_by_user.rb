module LayoutByUser
  extend ActiveSupport::Concern

  included do
    before_action :set_layout_by_controller
  end

  private

  def set_layout_by_controller
    if devise_controller?
      self.class.layout 'devise_application'
    else
      self.class.layout 'application'
    end
  end
end
