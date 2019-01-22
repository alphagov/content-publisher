# frozen_string_literal: true

class DocumentationController < ApplicationController
  before_action { authorise_user!(User::DEBUG_PERMISSION) }
end
