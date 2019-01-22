# frozen_string_literal: true

class User < ApplicationRecord
  include GDS::SSO::User
  serialize :permissions, Array

  PRE_RELEASE_FEATURES_PERMISSION = "pre_release_features"
  DEBUG_PERMISSION = "debug"
end
