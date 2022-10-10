RSpec.describe FeaturedAttachments::UpdateOrderInteractor do
  describe "#call" do
    let(:user) { build(:user) }
    let(:document_type) { build(:document_type, attachments: "featured") }
    let(:attachments) { create_list(:file_attachment_revision, 2) }
    let(:attachment_ids) { attachments.map(&:featured_attachment_id) }
    let(:ordering_params) { {} }

    let(:params) do
      ActionController::Parameters.new(document: edition.document.to_param,
                                       attachments: { ordering: ordering_params })
    end

    let(:edition) do
      create :edition,
             document_type:,
             file_attachment_revisions: attachments,
             featured_attachment_ordering: attachment_ids
    end

    before do
      stub_any_publishing_api_put_content
      stub_asset_manager_receives_an_asset
    end

    context "when the ordering is a sequence" do
      it "updates the edition with the new ordering" do
        ordering_params.merge!(attachment_ids[0] => "2", attachment_ids[1] => "1")
        described_class.call(params:, user:)
        expect(edition.reload.featured_attachment_ordering).to eq attachment_ids.reverse
      end
    end

    context "when the ordering is non-sequential" do
      it "updates the edition with the new ordering" do
        ordering_params.merge!(attachment_ids[0] => "100", attachment_ids[1] => "-2")
        described_class.call(params:, user:)
        expect(edition.reload.featured_attachment_ordering).to eq attachment_ids.reverse
      end
    end

    context "when the ordering is duplicated" do
      it "updates the edition with the new ordering" do
        ordering_params.merge!(attachment_ids[0] => "1", attachment_ids[1] => "1")
        described_class.call(params:, user:)
        expect(edition.reload.featured_attachment_ordering).to eq attachment_ids
      end
    end

    context "when the ordering is malformed" do
      it "updates the edition with the new ordering" do
        ordering_params.merge!("InvalidType1" => "1", attachment_ids[1] => "1")
        described_class.call(params:, user:)
        expect(edition.reload.featured_attachment_ordering).to eq attachment_ids
      end
    end

    context "when the ordering is not a hash" do
      it "updates the edition with the new ordering" do
        params[:attachments][:ordering] = ""
        described_class.call(params:, user:)
        expect(edition.reload.featured_attachment_ordering).to eq attachment_ids
      end
    end

    it "fails when the ordering is unchanged" do
      ordering_params.merge!(attachment_ids[0] => "1", attachment_ids[1] => "2")
      result = described_class.call(params:, user:)
      expect(result).to be_failure
    end
  end
end
