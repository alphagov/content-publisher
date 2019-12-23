# frozen_string_literal: true

RSpec.describe WhitehallImporter::MigrateAssets do
  describe ".call" do
    let(:asset) { build(:whitehall_imported_asset) }
    let(:whitehall_import) { build(:whitehall_import, assets: [asset]) }

    it "should take a WhitehallImport record as an argument" do
      expect { described_class.call(whitehall_import) }.not_to raise_error
    end

    it "should mark each asset as processing before marking as processed" do
      expect(asset).to receive(:update!).with(state: "processing").once.ordered
      expect(asset).to receive(:update!).with(state: "processed").once.ordered
      described_class.call(whitehall_import)
    end
  end
end
