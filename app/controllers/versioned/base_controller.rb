# frozen_string_literal: true

module Versioned
  class BaseController < ApplicationController
    before_action { authorise_user!(User::PRE_RELEASE_FEATURES_PERMISSION) }
  end
end
