GovukError.configure do |config|
  config.excluded_exceptions << "ApplicationController::Forbidden"

  # Don't capture postgres errors that occur during the time that the data sync
  # is running in integration and staging environments
  # This lambda is called with Ruby Exception objects, Raven::Event objects
  # and may be called with other types.
  config.should_capture = lambda { |error_or_event|
    data_sync_ignored_error = error_or_event.is_a?(PG::Error) ||
      (error_or_event.respond_to?(:cause) && error_or_event.cause.is_a?(PG::Error))
    data_sync_environment = ENV.fetch("SENTRY_CURRENT_ENV", "")
                               .match(/integration|staging/)
    data_sync_time = Time.zone.now.hour <= 5

    !(data_sync_ignored_error && data_sync_environment && data_sync_time)
  }
end
