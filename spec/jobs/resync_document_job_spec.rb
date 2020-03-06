RSpec.describe ResyncDocumentJob do
  it "delegates to the ResyncDocumentService" do
    document = build(:document)

    expect(ResyncDocumentService)
      .to receive(:call)
      .with(document)
    described_class.perform_now(document)
  end
end
