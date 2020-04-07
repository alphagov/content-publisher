RSpec.describe DocumentType::MultiTagField do
  describe "#updater_params" do
    let(:edition) { build :edition }
    let(:field) { described_class.new }

    before do
      allow(field).to receive(:id).and_return(:tag_id)
    end

    it "returns a hash of the topical_events" do
      params = ActionController::Parameters.new(tag_id: %w[some_tag_value])
      updater_params = field.updater_params(edition, params)
      expect(updater_params).to eq(tag_id: %w[some_tag_value])
    end

    it "removes nil values from the hash of tags" do
      params = ActionController::Parameters.new(tag_id: nil)
      updater_params = field.updater_params(edition, params)
      expect(updater_params).to eq({})
    end
  end
end
