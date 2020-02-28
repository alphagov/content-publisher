GovukError.configure do |config|
  config.excluded_exceptions << "ApplicationController::Forbidden"
end
