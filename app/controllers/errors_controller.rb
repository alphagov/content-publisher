# frozen_string_literal: true

class ErrorsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :check_user_access

  def bad_request
    render status: :bad_request, formats: :html
  end

  def not_found
    render status: :not_found, formats: :html
  end

  def unprocessable_entity
    render status: :unprocessable_entity, formats: :html
  end

  def internal_server_error
    render status: :internal_server_error, formats: :html
  end
end
