# frozen_string_literal: true

class ErrorsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :set_current_user
  skip_before_action :set_paper_trail_whodunnit
  skip_before_action :set_layout_by_controller
  layout 'errors'

  def not_found
    render status: :not_found
  end

  def unprocessable_entity
    render status: :unprocessable_entity
  end

  def internal_server_error
    render status: :internal_server_error
  end

  def unauthorized
    render status: :forbidden
  end
end
