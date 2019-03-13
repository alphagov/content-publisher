# frozen_string_literal: true

class AbortWorkerError < RuntimeError; end

class SidekiqAbortMiddleware
  def call(_worker, _job, _queue)
    yield
  rescue AbortWorkerError => e
    Sidekiq.logger.warn(e.message)
  end
end
