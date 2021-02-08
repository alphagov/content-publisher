class ApplicationJob < ActiveJob::Base
  def self.discard_and_log(exception)
    discard_on(exception) { |_, error| Rails.logger.warn(error) }
  end

  def run_exclusively(lock_name: self.class.name, &block)
    name = "content-publisher:#{lock_name}"
    options = { timeout_seconds: 0, transaction: true }

    result = ApplicationRecord.transaction do
      ApplicationRecord.with_advisory_lock_result(name, options, &block)
    end

    unless result.lock_was_acquired?
      logger.info("Job skipped as exclusive lock '#{name}' could not be acquired")
    end

    result.result
  end
end
