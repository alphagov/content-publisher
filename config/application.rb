require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ContentPublisher
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # TODO: remove once upgraded to Rails 7
    config.active_support.cache_format_version = 6.1

    # Rotate SHA1 cookies to SHA256 (the new Rails 7 default)
    # TODO: Remove this after existing user sessions have been rotated
    # https://guides.rubyonrails.org/v7.0/upgrading_ruby_on_rails.html#key-generator-digest-class-changing-to-use-sha256
    Rails.application.config.action_dispatch.cookies_rotations.tap do |cookies|
      salt = Rails.application.config.action_dispatch.authenticated_encrypted_cookie_salt
      secret_key_base = Rails.application.secrets.secret_key_base
      next if secret_key_base.blank?

      key_generator = ActiveSupport::KeyGenerator.new(
        secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA1
      )
      key_len = ActiveSupport::MessageEncryptor.key_len
      secret = key_generator.generate_key(salt, key_len)

      cookies.rotate :encrypted, secret
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.i18n.raise_on_missing_translations = true
    config.i18n.load_path += Dir[Rails.root.join("config/locales/**/*.yml")]
    config.active_job.queue_adapter = :sidekiq
    config.time_zone = "London"
    config.eager_load_paths << Rails.root.join("lib")
    config.autoload_paths << Rails.root.join("lib")
    config.exceptions_app = routes
    config.action_dispatch.rescue_responses.merge!(
      "ApplicationController::Forbidden" => :forbidden,
    )

    # Rails 7 defaults to using libvips instead of ImageMagick for processing
    # ActiveStorage variants - we'd need to install vips on our production
    # hosts and update variant config to use this.
    Rails.application.config.active_storage.variant_processor = :mini_magick

    # Rails 6.1 introduced this new configuration option that has compatibility
    # problems with Content Publisher. It uploads an ActiveStorage variant
    # after a transaction is commited [1]. This causes problems for us when
    # we want to create a variant to be sent to Asset Manager during a
    # transaction [2]. For now this option is switched off.
    #
    # [1]: https://github.com/rails/rails/blob/6ce14ee4bc6b6d0ca4a4e8f9a235b00daeb9bab1/activestorage/lib/active_storage/attached/model.rb#L77
    # [2]: https://github.com/alphagov/content-publisher/blob/3c3c5bf489a75c9ef7041eece6d6bbb03a280642/app/models/image/blob_revision.rb#L37-L51
    config.active_storage.track_variants = false

    # We don't utilise the JS assets for activestorage and thus don't want them
    # compiled - they also cause an error as they use ES6 syntax
    config.active_storage.precompile_assets = false

    # Using a sass css compressor causes a scss file to be processed twice
    # (once to build, once to compress) which breaks the usage of "unquote"
    # to use CSS that has same function names as SCSS such as max.
    # https://github.com/alphagov/govuk-frontend/issues/1350
    config.assets.css_compressor = nil

    unless Rails.application.secrets.jwt_auth_secret
      raise "JWT auth secret is not configured. See config/secrets.yml"
    end
  end
end
