# frozen_string_literal: true

class PopulateBulkDataJob < ApplicationJob
  retry_on BulkData::RemoteDataUnavailableError

  def perform
    run_exclusively do
      BulkData::GovernmentRepository.new.populate_cache(older_than: 5.minutes.ago)
    end
  end
end
