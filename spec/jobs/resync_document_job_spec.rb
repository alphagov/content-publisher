RSpec.describe ResyncDocumentJob do
  include ActiveJob::TestHelper

  let(:document) { create(:document) }

  before { populate_default_government_bulk_data }

  it "delegates to the ResyncDocumentService" do
    expect(ResyncDocumentService)
      .to receive(:call)
      .with(document)
    described_class.perform_now(document)
  end

  it "retries the job when an exception is raised" do
    allow(ResyncDocumentService).to receive(:call).and_raise(GdsApi::BaseError)
    described_class.perform_now(document)

    expect(described_class).to have_been_enqueued
  end
end
