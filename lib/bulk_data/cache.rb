module BulkData
  class Cache
    include Singleton

    class NoEntryError < RuntimeError; end

    class << self
      delegate :cache, to: :instance
      delegate :clear, :exist?, :middleware, to: :cache
    end

    attr_reader :cache

    def self.write(key, value)
      cache.write(key, value, expires_in: 24.hours)
      cache.write("#{key}:created", Time.zone.now, expires_in: 24.hours)
    end

    def self.read(key)
      cache.read(key) || (raise NoEntryError)
    end

    def self.written_at(key)
      return unless cache.exist?(key)

      cache.read("#{key}:created")
    end

    def self.written_after?(key, time)
      created = written_at(key)
      return false unless created

      created > time
    end

    def self.delete(key)
      cache.delete(key)
      cache.delete("#{key}:created")
    end

  private

    def initialize
      @cache = ActiveSupport::Cache::RedisCacheStore.new(
        namespace: "content-publisher:bulk-data-cache-#{Rails.env}",
        error_handler: ->(exception:, **) { GovukError.notify(exception) },
        reconnect_attempts: [0.1, 0.1, 0.1],
      )
    end
  end
end
