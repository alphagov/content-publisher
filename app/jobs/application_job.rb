# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  def self.discard_and_log(exception)
    discard_on(exception) { |_, error| Rails.logger.warn(error) }
  end

  def run_exclusively(transaction: true, lock_name: self.class.name)
    name = "content-publisher:#{lock_name}"
    options = { timeout_seconds: 0, transaction: transaction }
    result = if transaction
               ApplicationRecord.transaction do
                 ApplicationRecord.with_advisory_lock_result(name, options) { yield }
               end
             else
               ApplicationRecord.with_advisory_lock_result(name, options) { yield }
             end

    unless result.lock_was_acquired?
      logger.info("Job skipped as exclusive lock '#{name}' could not be acuqired")
    end

    result.result
  end
end
