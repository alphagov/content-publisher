GovukError.configure do |config|
  config.excluded_exceptions << "ApplicationController::Forbidden"

  # Don't capture postgres errors that occur during the time that the data sync
  # is running in integration and staging environments
  config.should_capture = ->(error) do
    data_sync_ignored_error = error.is_a?(PG::Error) || error.cause.is_a?(PG::Error)
    data_sync_environment = ENV.fetch("SENTRY_CURRENT_ENV", "")
                               .match(/integration|staging/)
    data_sync_time = Time.zone.now.hour <= 5

    !(data_sync_ignored_error && data_sync_environment && data_sync_time)
  end
end
