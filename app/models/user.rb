# frozen_string_literal: true

class User < ApplicationRecord
  include GDS::SSO::User
  has_many :documents, foreign_key: :creator_id, inverse_of: :creator, dependent: :restrict_with_exception
  serialize :permissions, Array
end
