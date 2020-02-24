RSpec.describe DiscardPathReservationsService do
  describe ".call" do
    it "unreserves an edition's path reservations" do
      edition = create(:edition)
      previous_revision = create(:revision)
      edition.revisions << previous_revision

      unreserve_request1 = stub_publishing_api_unreserve_path(
        edition.base_path,
        PublishingApiPayload::PUBLISHING_APP,
      )

      unreserve_request2 = stub_publishing_api_unreserve_path(
        previous_revision.base_path,
        PublishingApiPayload::PUBLISHING_APP,
      )

      described_class.call(edition)

      expect(unreserve_request1).to have_been_requested
      expect(unreserve_request2).to have_been_requested
    end

    it "copes if the base path is not reserved" do
      edition = create(:edition)
      request = stub_publishing_api_unreserve_path_not_found(edition.base_path)
      described_class.call(edition)
      expect(request).to have_been_requested
    end

    it "doesn't discard base paths that are missing" do
      edition = create(:edition, base_path: nil)
      request = stub_any_publishing_api_unreserve_path
      described_class.call(edition)
      expect(request).not_to have_been_requested
    end
  end
end
