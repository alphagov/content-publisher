# frozen_string_literal: true

class DocumentationController < ApplicationController
  include GDS::SSO::ControllerMethods
  before_action { authorise_user!(User::DEBUG_PERMISSION) }
end
