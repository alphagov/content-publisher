# frozen_string_literal: true

RSpec.describe PopulateBulkDataJob do
  include ActiveJob::TestHelper

  it "runs the job exclusively" do
    job = PopulateBulkDataJob.new
    expect(job).to receive(:run_exclusively)
    job.perform
  end

  it "populates government caches older than 5 minutes" do
    freeze_time do
      repository = instance_double("BulkData::GovernmentRepository")
      expect(BulkData::GovernmentRepository).to receive(:new).and_return(repository)
      expect(repository).to receive(:populate_cache)
                        .with(older_than: 5.minutes.ago)

      PopulateBulkDataJob.perform_now
    end
  end

  it "retries the job when the BulkData::RemoteDataUnavailableError is raised" do
    expect(BulkData::GovernmentRepository)
      .to receive(:new)
      .and_raise(BulkData::RemoteDataUnavailableError)

    PopulateBulkDataJob.perform_now
    expect(PopulateBulkDataJob).to have_been_enqueued
  end
end
