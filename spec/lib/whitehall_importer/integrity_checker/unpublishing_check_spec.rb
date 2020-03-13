RSpec.describe WhitehallImporter::IntegrityChecker::UnpublishingCheck do
  let(:withdrawal) { build(:withdrawal) }
  let(:withdrawn_edition) { build(:edition, :withdrawn, withdrawal: withdrawal) }
  let(:removal) { build(:removal) }
  let(:removal_with_redirect) do
    build(:removal, alternative_url: "/somewhere", redirect: true)
  end

  let(:removed_edition) { build(:edition, :removed, removal: removal) }
  let(:removed_edition_with_redirect) do
    build(:edition, :removed, removal: removal_with_redirect)
  end

  describe "#expected_type?" do
    context "when imported edition is withdrawn" do
      it "returns true if it has a 'withdrawal' unpublishing type in Publishing API" do
        unpublishing_check = described_class.new(withdrawn_edition,
                                                 publishing_api_withdrawal)
        expect(unpublishing_check.expected_type?).to be true
      end

      it "returns false if it does not have a 'withdrawal' unpublishing type in Publishing API" do
        unpublishing_check = described_class.new(withdrawn_edition,
                                                 publishing_api_redirect)
        expect(unpublishing_check.expected_type?).to be false
      end
    end

    context "when imported edition is removed" do
      it "returns true if it has a 'gone' unpublishing type in the Publishing API" do
        unpublishing_check = described_class.new(removed_edition, publishing_api_gone)
        expect(unpublishing_check.expected_type?).to be true
      end

      it "returns false if it does not have a 'gone' unpublishing type in the Publishing API" do
        unpublishing_check = described_class.new(removed_edition,
                                                 publishing_api_redirect)
        expect(unpublishing_check.expected_type?).to be false
      end
    end

    context "when imported edition is removed and redirected" do
      it "returns true if it has a 'redirect' unpublishing type in the Publishing API" do
        unpublishing_check = described_class.new(removed_edition_with_redirect,
                                                 publishing_api_redirect)
        expect(unpublishing_check.expected_type?).to be true
      end

      it "returns false if it does not have a 'redirect' unpublishing type in the Publishing API" do
        unpublishing_check = described_class.new(removed_edition_with_redirect,
                                                 publishing_api_gone)
        expect(unpublishing_check.expected_type?).to be false
      end
    end
  end

  describe "#expected_unpublishing_time?" do
    context "when imported edition is withdrawn" do
      it "returns true if withdrawn_at matches unpublished_at in Publishing API" do
        unpublishing_check = described_class.new(withdrawn_edition,
                                                 publishing_api_withdrawal)

        expect(unpublishing_check.expected_unpublishing_time?).to be true
      end

      it "returns false if withdrawn_at does not match unpublished_at in Publishing API" do
        unpublished_at = { "unpublished_at" => Date.yesterday.end_of_day }
        unpublishing_check = described_class.new(withdrawn_edition,
                                                 publishing_api_withdrawal(unpublished_at))

        expect(unpublishing_check.expected_unpublishing_time?).to be false
      end
    end

    context "when imported edition is removed" do
      it "returns true even if removed_at does not match unpublished_at in Publishing API" do
        unpublished_at = { "unpublished_at" => Date.yesterday.end_of_day }
        unpublishing_check = described_class.new(removed_edition,
                                                 publishing_api_gone(unpublished_at))

        expect(unpublishing_check.expected_unpublishing_time?).to be true
      end
    end
  end

  def publishing_api_withdrawal(attributes = {})
    {
      "type" => "withdrawal",
      "unpublished_at" => withdrawal.withdrawn_at.rfc3339,
    }.merge(attributes).as_json
  end

  def publishing_api_gone(attributes = {})
    {
      "type" => "gone",
    }.merge(attributes).as_json
  end

  def publishing_api_redirect(attributes = {})
    {
      "type" => "redirect",
    }.merge(attributes).as_json
  end
end
