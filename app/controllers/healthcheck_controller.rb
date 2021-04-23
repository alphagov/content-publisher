class HealthcheckController < ApplicationController
  skip_before_action :authenticate_user!

  def government_data
    render json: Healthcheck::GovernmentDataCheck.new.to_hash
  end
end
