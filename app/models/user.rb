# frozen_string_literal: true

class User < ApplicationRecord
  include GDS::SSO::User

  serialize :permissions, Array
end
