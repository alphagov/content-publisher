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
    config.load_defaults 6.1

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

    # Rails 6.1 introduced this new configuration option that has compatibility
    # problems with Content Publisher. It uploads an ActiveStorage variant
    # after a transaction is commited [1]. This causes problems for us when
    # we want to create a variant to be sent to Asset Manager during a
    # transaction [2]. For now this option is switched off.
    #
    # [1]: https://github.com/rails/rails/blob/6ce14ee4bc6b6d0ca4a4e8f9a235b00daeb9bab1/activestorage/lib/active_storage/attached/model.rb#L77
    # [2]: https://github.com/alphagov/content-publisher/blob/3c3c5bf489a75c9ef7041eece6d6bbb03a280642/app/models/image/blob_revision.rb#L37-L51
    config.active_storage.track_variants = false

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
