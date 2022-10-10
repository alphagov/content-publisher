RSpec.describe FileAttachments::UpdateInteractor do
  describe ".call" do
    let(:user) { create(:user) }
    let(:attachment_params) { {} }
    let(:attachment_revision) { build :file_attachment_revision, paper_number: "123" }

    let(:edition) do
      create(:edition,
             document_type: build(:document_type, attachments: "featured"),
             file_attachment_revisions: [attachment_revision])
    end

    let(:params) do
      ActionController::Parameters.new(
        document: edition.document.to_param,
        file_attachment_id: attachment_revision.file_attachment_id,
        file_attachment: attachment_params,
      )
    end

    before do
      stub_any_publishing_api_put_content
      stub_asset_manager_receives_an_asset
    end

    context "with unnumbered command papers" do
      it "overrides the official document type and number" do
        attachment_params.merge!(official_document_type: "unnumbered_command_paper",
                                 command_paper_number: "CP 1234")
        result = described_class.call(params:, user:)
        expect(result.file_attachment_revision).to be_command_paper
        expect(result.file_attachment_revision.paper_number).to be_blank
      end
    end

    context "with unnumbered act papers" do
      it "overrides the official document type and number" do
        attachment_params.merge!(official_document_type: "unnumbered_act_paper",
                                 act_paper_number: "1234")
        result = described_class.call(params:, user:)
        expect(result.file_attachment_revision).to be_act_paper
        expect(result.file_attachment_revision.paper_number).to be_blank
      end
    end

    context "with unofficial documents" do
      it "overrides the official document type and number" do
        attachment_params.merge!(official_document_type: "unofficial",
                                 command_paper_number: "CP 1234")
        result = described_class.call(params:, user:)
        expect(result.file_attachment_revision).to be_unofficial
        expect(result.file_attachment_revision.paper_number).to be_blank
      end
    end

    context "with numbered command papers" do
      it "overrides the official document type and number" do
        attachment_params.merge!(official_document_type: "command_paper",
                                 command_paper_number: "CP 1234")
        result = described_class.call(params:, user:)
        expect(result.file_attachment_revision).to be_command_paper
        expect(result.file_attachment_revision.paper_number).to eq "CP 1234"
      end
    end

    context "with numbered act papers" do
      it "overrides the official document type and number" do
        attachment_params.merge!(official_document_type: "act_paper",
                                 act_paper_number: "1234")
        result = described_class.call(params:, user:)
        expect(result.file_attachment_revision).to be_act_paper
        expect(result.file_attachment_revision.paper_number).to eq "1234"
      end
    end
  end
end
