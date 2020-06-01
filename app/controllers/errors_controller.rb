class ErrorsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token
  skip_before_action :check_user_access

  before_action do
    # retrieves an existing sesssion for users if available. Unlike
    # `authenticate_user!` this does not redirect a user when they are not
    # authenticated.
    warden&.authenticate
  end

  def bad_request
    render status: :bad_request, formats: :html
  end

  def forbidden
    render status: :forbidden, formats: :html
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
