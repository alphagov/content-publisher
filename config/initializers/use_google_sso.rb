module GDS
  module SSO
    class Engine
      def self.default_strategies
        [:google_oauth2]
      end
    end
  end
end

module GDS
  module SSO
    class FailureApp
      def redirect
        store_location!
        redirect_to "/auth/google_oauth2"
      end
    end
  end
end

Warden::Strategies.add(:google_oauth2) do
  def valid?
    true
  end

  def authenticate!
    logger.debug("Authenticating with gds_sso strategy")

    if request.env["omniauth.auth"].nil?
      fail!("No credentials, bub")
    else
      user = prep_user(request.env["omniauth.auth"])
      success!(user)
    end
  end

  private

  def prep_user(auth_hash)
    user = find_for_gds_oauth(auth_hash)
    fail!("Couldn't process credentials") unless user
    user
  end

  def find_for_gds_oauth(auth_hash)
    user_params = user_params_from_auth_hash(auth_hash.to_hash)
    user = User.where(uid: user_params["uid"]).first ||
      User.where(email: user_params["email"]).first

    if user
      user.update!(user_params)
      user
    else # Create a new user.
      User.create!(user_params)
    end
  end

  def user_params_from_auth_hash(auth_hash)
    {
      "uid" => auth_hash["uid"],
      "email" => auth_hash["info"]["email"],
      "name" => auth_hash["info"]["name"],
    }
  end
end

Warden::OAuth2.configure do |config|
  config.token_model = GDS::SSO::Config.use_mock_strategies? ? GDS::SSO::MockBearerToken : GDS::SSO::BearerToken
end
Warden::Strategies.add(:gds_bearer_token, Warden::OAuth2::Strategies::Bearer)

Warden::Strategies.add(:mock_gds_sso) do
  def valid?
    !::GDS::SSO::ApiAccess.api_call?(env)
  end

  def authenticate!
    logger.warn("Authenticating with mock_gds_sso strategy")

    test_user = GDS::SSO.test_user
    test_user ||= ENV["GDS_SSO_MOCK_INVALID"].present? ? nil : GDS::SSO::Config.user_klass.first
    if test_user
      # Brute force ensure test user has correct perms to signin
      unless test_user.has_permission?("signin")
        permissions = test_user.permissions || []
        test_user.update_attribute(:permissions, permissions << "signin")
      end
      success!(test_user)
    elsif Rails.env.test? && ENV["GDS_SSO_MOCK_INVALID"].present?
      fail!(:invalid)
    else
      raise "GDS-SSO running in mock mode and no test user found. Normally we'd load the first user in the database. Create a user in the database."
    end
  end
end

Rails.application.config.middleware.swap OmniAuth::Builder, OmniAuth::Builder do
  provider :google_oauth2, ENV.fetch("GOOGLE_CLIENT_ID"), ENV.fetch("GOOGLE_CLIENT_SECRET")
end
