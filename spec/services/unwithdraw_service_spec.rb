# frozen_string_literal: true

RSpec.describe UnwithdrawService do
  before do
    @user = create(:user)
  end

  describe "#call" do
    it "adds an entry in the timeline of the document" do
      withdrawn_edition = create(:edition, :withdrawn)
      stub_publishing_api_republish(withdrawn_edition.content_id, {})

      UnwithdrawService.new.call(withdrawn_edition, @user)

      expect(withdrawn_edition.timeline_entries.first.entry_type).to eq("unwithdrawn")
    end

    it "creates a new status with the same state as the previously published version" do
      withdrawn_edition = create(:edition, :withdrawn)
      stub_publishing_api_republish(withdrawn_edition.content_id, {})

      withdrawal = withdrawn_edition.status.details
      previous_published_status = withdrawal.published_status

      UnwithdrawService.new.call(withdrawn_edition, @user)
      withdrawn_edition.reload

      expect(previous_published_status.state).to eq(withdrawn_edition.status.state)
      expect(previous_published_status).to_not eq(withdrawn_edition.status)
    end

    it "makes a republish request" do
      edition = create(:edition, :withdrawn)
      republish_request = stub_publishing_api_republish(edition.content_id, {})

      UnwithdrawService.new.call(edition, @user)

      expect(republish_request).to have_been_requested
    end

    it "raises an error if current edition is not withdrawn" do
      published_edition = create(:edition, :published)

      expect { UnwithdrawService.new.call(published_edition, @user) }.to raise_error(
        "edition must be withdrawn to be unwithdrawn",
      )
    end
  end
end
