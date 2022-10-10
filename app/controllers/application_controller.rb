class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  include EditionAssertions

  class Forbidden < RuntimeError; end

  helper_method :rendering_context
  layout -> { rendering_context }

  before_action :authenticate_user!
  before_action { Sentry.set_user(id: current_user&.uid) }
  before_action :check_user_access

  add_flash_types :alert_with_description,
                  :tried_to_publish,
                  :tried_to_preview

  rescue_from EditionAssertions::StateError do |e|
    Rails.logger.warn(e.message)

    if rendering_context == "modal"
      raise ActionController::BadRequest
    elsif e.edition.first? && e.edition.discarded?
      redirect_to documents_path
    else
      redirect_to document_path(e.edition.document)
    end
  end

  rescue_from EditionAssertions::FeatureError do |e|
    raise ActionController::RoutingError, e.message
  end

  rescue_from BulkData::LocalDataUnavailableError do |error|
    GovukError.notify(error)

    render "errors/local_data_unavailable",
           locals: { error: },
           status: :service_unavailable
  end

  def rendering_context
    request.headers["Content-Publisher-Rendering-Context"] || "application"
  end

  def check_user_access
    document_param = request.path_parameters[:document]
    return if document_param.blank?

    edition = Edition
      .includes(:access_limit, revision: [:tags_revision])
      .find_current(document: document_param)

    if edition.document_type.pre_release? &&
        !current_user.has_permission?(User::PRE_RELEASE_FEATURES_PERMISSION)

      raise Forbidden
    end

    unless current_user.can_access?(edition)
      render "documents/access_limited", status: :forbidden,
                                         assigns: { edition: }
    end
  end
end
