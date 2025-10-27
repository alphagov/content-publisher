Rails.application.routes.draw do
  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response(
    GovukHealthcheck::ActiveRecord,
    GovukHealthcheck::SidekiqRedis,
    Healthcheck::ActiveStorage,
  )

  get "/healthcheck/government-data", to: "healthcheck#government_data"

  get "/*all", to: redirect("/")
  get "/", to: proc { [200, {}, ["Content Publisher is currently mid-migration to Whitehall and can no longer be accessed."]] }
end
