RSpec.describe PopulateBulkDataJob do
  include ActiveJob::TestHelper

  it "runs the job exclusively" do
    job = described_class.new
    expect(job).to receive(:run_exclusively)
    job.perform
  end

  it "populates government caches older than 5 minutes" do
    freeze_time do
      repository = instance_double("BulkData::GovernmentRepository")
      expect(BulkData::GovernmentRepository).to receive(:new).and_return(repository)
      expect(repository).to receive(:populate_cache)
                        .with(older_than: 5.minutes.ago)

      described_class.perform_now
    end
  end

  it "retries the job when the BulkData::RemoteDataUnavailableError is raised" do
    expect(BulkData::GovernmentRepository)
      .to receive(:new)
      .and_raise(BulkData::RemoteDataUnavailableError)

    described_class.perform_now
    expect(described_class).to have_been_enqueued
  end

  it "logs the cause of BulkData::RemoteDataUnavailableErrors" do
    error = GdsApi::TimedOutException.new
    stub_any_publishing_api_call.to_raise(error)

    job = described_class.new
    expect(job.logger).to receive(:warn).with(error.inspect)
    expect { job.perform }.to raise_error(BulkData::RemoteDataUnavailableError)
  end

  context "when it runs out of retries" do
    it "reports the error to GovukError" do
      stub_publishing_api_isnt_available

      perform_enqueued_jobs do
        expect(GovukError).to receive(:notify)
                          .with(instance_of(BulkData::RemoteDataUnavailableError))
        described_class.perform_later
      end
    end
  end
end
