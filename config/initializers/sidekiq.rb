# frozen_string_literal: true

require "sidekiq_abort_middleware"

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add SidekiqAbortMiddleware
  end
end
