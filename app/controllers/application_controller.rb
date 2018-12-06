# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods

  before_action :authenticate_user!

  add_flash_types :alert_with_description, :alert_with_items, :confirmation, :tried_to_publish, :tried_to_preview

  before_action :set_paper_trail_whodunnit
end
