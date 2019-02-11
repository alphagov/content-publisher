# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods

  before_action :authenticate_user!
  before_action { Raven.user_context(id: current_user&.uid) }

  add_flash_types :alert_with_description, :alert_with_items, :confirmation, :tried_to_publish, :tried_to_preview
end
