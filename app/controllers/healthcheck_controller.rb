class HealthcheckController < ApplicationController
  skip_before_action :authenticate_user!

  def active_storage
    render json: Healthcheck::ActiveStorage.new.to_hash
  end

  def government_data
    render json: Healthcheck::GovernmentDataCheck.new.to_hash
  end
end
