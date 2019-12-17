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

  context "when it runs out of retries" do
    it "reports the error to GovukError if the cause is not a GdsApi::HTTPServerError" do
      stub_any_publishing_api_call.to_return(status: 429)

      perform_enqueued_jobs do
        expect(GovukError).to receive(:notify)
                          .with(instance_of(BulkData::RemoteDataUnavailableError))
        PopulateBulkDataJob.perform_later
      end
    end

    it "doesn't report the error to GovukError when the cause is a GdsApi::HTTPServerError" do
      stub_any_publishing_api_call.to_return(status: 500)

      perform_enqueued_jobs do
        expect(GovukError).not_to receive(:notify)
        PopulateBulkDataJob.perform_later
      end
    end
  end
end
