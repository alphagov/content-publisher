# frozen_string_literal: true

module AuthenticationHelper
  def login_as(user)
    GDS::SSO.test_user = user
  end

  def current_user
    GDS::SSO.test_user || User.first
  end

  def reset_authentication
    GDS::SSO.test_user = nil
  end
end
