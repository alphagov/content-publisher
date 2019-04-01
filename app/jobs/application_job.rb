# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  def self.discard_and_log(exception)
    discard_on(exception) { |_, error| Rails.logger.warn(error) }
  end
end
