class PopulateBulkDataJob < ApplicationJob
  # The last retry will be 2 hours 46 mins later which should be an indication
  # of a long running problem.
  retry_on(
    BulkData::RemoteDataUnavailableError,
    wait: :polynomially_longer,
    attempts: 10,
  ) { |_job, error| GovukError.notify(error) }

  def perform
    run_exclusively do
      BulkData::GovernmentRepository.new.populate_cache(older_than: 5.minutes.ago)
    end
  rescue BulkData::RemoteDataUnavailableError => e
    logger.warn(e.cause ? e.cause.inspect : e.inspect)
    raise
  end
end
