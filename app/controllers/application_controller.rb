# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods

  before_action :authenticate_user!

  add_flash_types :alert_with_description, :confirmation, :tried_to_publish

  before_action :set_paper_trail_whodunnit
end
