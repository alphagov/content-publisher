# frozen_string_literal: true

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
