# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  include Assertions

  helper_method :rendering_context

  before_action :authenticate_user!
  before_action { Raven.user_context(id: current_user&.uid) }

  add_flash_types :alert_with_description, :alert_with_items, :confirmation, :tried_to_publish, :tried_to_preview

  #rescue_from Edition::IntegrityAssertionError do |e|
    #Rails.logger.error(e.message)
    #redirect_to document_path(params[:document])
  #end

  rescue_from Assertions::ErrorWithEdition do |e|
    Rails.logger.error(e.message)
    redirect_to document_path(e.edition.document)
  end

  rescue_from Assertions::PermissionError do |e|
    Rails.logger.warn(e.message)
    render :permission_error, assigns: { permission: e.permission }, status: :forbidden
  end

  rescue_from Assertions::AccessError do |e|
    Rails.logger.warn(e.message)
    render :access_error, status: :forbidden
  end

  def rendering_context
    request.headers["Content-Publisher-Rendering-Context"] || "application"
  end
end
