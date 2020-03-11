RSpec.describe WhitehallImporter::IntegrityChecker::UnpublishingCheck do
  let(:withdrawal_explanation) { "This has been moved" }
  let(:withdrawal) do
    build(:withdrawal,
          public_explanation: "#{withdrawal_explanation} [elsewhere](https://www.gov.uk/elsewhere)")
  end

  let(:withdrawn_edition) { build(:edition, :withdrawn, withdrawal: withdrawal) }
  let(:removed_explanation) { "This has been removed" }
  let(:removal) do
    build(:removal,
          explanatory_note: "#{removed_explanation} [Visit here](https://www.gov.uk/here)")
  end
  let(:removed_edition) { build(:edition, :removed, removal: removal) }

  let(:removal_with_redirect) do
    build(:removal,
          alternative_url: "/somewhere",
          redirect: true)
  end

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

  describe "#expected_type" do
    it "returns 'withdrawal' when edition is withdrawn" do
      unpublishing_check = described_class.new(withdrawn_edition,
                                               publishing_api_withdrawal)
      expect(unpublishing_check.expected_type).to eq "withdrawal"
    end

    it "returns 'gone' when edition is removed" do
      unpublishing_check = described_class.new(removed_edition,
                                               publishing_api_gone)
      expect(unpublishing_check.expected_type).to eq "gone"
    end

    it "returns 'redirect' when edition is removed and redirected" do
      unpublishing_check = described_class.new(removed_edition_with_redirect,
                                               publishing_api_redirect)
      expect(unpublishing_check.expected_type).to eq "redirect"
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

  describe "#expected_unpublishing_time" do
    it "returns withdrawn_at for withdrawn editions" do
      unpublishing_check = described_class.new(withdrawn_edition,
                                               publishing_api_withdrawal)

      expect(unpublishing_check.expected_unpublishing_time)
        .to eq(withdrawal.withdrawn_at)
    end
  end

  describe "#expected_alternative_path?" do
    context "when imported edition is withdrawn" do
      it "returns true and does not check for an alternative path" do
        unpublishing_check = described_class.new(withdrawn_edition,
                                                 publishing_api_withdrawal)

        expect(unpublishing_check.expected_alternative_path?).to be true
      end
    end

    context "when imported edition is removed and redirected" do
      it "returns true if alternative_url matches alternative_path in Publishing API" do
        unpublishing_check = described_class.new(removed_edition_with_redirect,
                                                 publishing_api_redirect)
        expect(unpublishing_check.expected_alternative_path?).to be true
      end

      it "returns false if alternative_url does not match alternative_path in Publishing API" do
        alternative_path = { "alternative_path" => "/somewhere-else" }
        unpublishing_check = described_class.new(removed_edition_with_redirect,
                                                 publishing_api_redirect(alternative_path))
        expect(unpublishing_check.expected_alternative_path?).to be false
      end
    end
  end

  describe "#expected_alternative_path" do
    it "returns the edition's alternative_url" do
      unpublishing_check = described_class.new(removed_edition_with_redirect,
                                               publishing_api_redirect)
      expect(unpublishing_check.expected_alternative_path)
        .to eq(removal_with_redirect.alternative_url)
    end
  end

  describe "#expected_explanation?" do
    context "when imported edition is withdrawn" do
      it "returns true if public_explanation matches explanation in Publishing API" do
        unpublishing_check = described_class.new(withdrawn_edition,
                                                 publishing_api_withdrawal)
        expect(unpublishing_check.expected_explanation?).to be true
      end

      it "returns false if public_explanation does not match explanation in Publishing API" do
        explanation = { "explanation" => "Another explanation" }
        unpublishing_check = described_class.new(withdrawn_edition,
                                                 publishing_api_withdrawal(explanation))
        expect(unpublishing_check.expected_explanation?).to be false
      end
    end

    context "when imported edition is removed" do
      it "returns true if explanatory_note matches explanation in Publishing API" do
        unpublishing_check = described_class.new(removed_edition,
                                                 publishing_api_gone)
        expect(unpublishing_check.expected_explanation?).to be true
      end

      it "returns false if explanatory_note does not match explanation in Publishing API" do
        explanation = { "explanation" => "Another explanation" }
        unpublishing_check = described_class.new(removed_edition,
                                                 publishing_api_gone(explanation))
        expect(unpublishing_check.expected_explanation?).to be false
      end
    end
  end

  def publishing_api_withdrawal(attributes = {})
    {
      "type" => "withdrawal",
      "unpublished_at" => withdrawal.withdrawn_at.rfc3339,
      "explanation" => "#{withdrawal_explanation} <a href=\"https://www.gov.uk/elsewhere\">elsewhere</a>",
    }.merge(attributes).as_json
  end

  def publishing_api_gone(attributes = {})
    {
      "type" => "gone",
      "explanation" => "#{removed_explanation} <a href=\"https://www.gov.uk/here\">Visit here</a>",
    }.merge(attributes).as_json
  end

  def publishing_api_redirect(attributes = {})
    {
      "type" => "redirect",
      "alternative_path" => "/somewhere",
    }.merge(attributes).as_json
  end
end
