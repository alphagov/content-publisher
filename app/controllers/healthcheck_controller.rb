class HealthcheckController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    checks = [
      GovukHealthcheck::SidekiqRedis,
      GovukHealthcheck::ActiveRecord,
      Healthcheck::GovernmentDataCheck,
    ]

    checks << Healthcheck::ActiveStorage if params[:storage]
    render json: GovukHealthcheck.healthcheck(checks)
  end
end
