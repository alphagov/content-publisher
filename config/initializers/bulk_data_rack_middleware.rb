# We need to explicitly 'require' the BulkData::Cache in development so that
# the singleton instance here continues to be used in requests. Otherwise the
# caching described below will only apply to the orphaned singleton. This has
# the small risk of confusion that the BulkData::Cache class won't reload
# automatically when its content changes.
#
# To verify: add a `puts BulkData::Cache.object_id` below and then see that
# the `object_id` is (not) the same in a console.
#
# https://guides.rubyonrails.org/v5.2/autoloading_and_reloading_constants.html#autoloading-and-initializers
# https://guides.rubyonrails.org/v5.2/autoloading_and_reloading_constants.html#autoloading-and-require
require "bulk_data"
require "bulk_data/cache"

# This is used to set a local cache that runs on BulkData for the duration of
# a request. This means if we look up the same item in the cache multiple
# times during a single request it will only hit Redis once and then look up
# the item in memory.
#
# For more details see: https://github.com/rails/rails/blob/fa292703e1b733a7a55a8d6f0d749ddf590c61fd/activesupport/lib/active_support/cache/strategy/local_cache.rb
Rails.application.config.middleware.insert_before(
  ::Rack::Runtime,
  BulkData::Cache.middleware,
)
