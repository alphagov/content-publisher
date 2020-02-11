RSpec.describe GdsApi::WhitehallExport do
  let(:whitehall_adapter) { described_class.new(Plek.find("whitehall-admin")) }
  let(:whitehall_host) { Plek.new.external_url_for("whitehall-admin") }
  let(:document_id) { "123" }

  describe "#document_list" do
    it "iterates through the correct number of pages" do
      first_page = stub_whitehall_has_document_index(
        document_id, "news_article", %w(news_story press_release), 1, 100
      )
      second_page = stub_whitehall_has_document_index(
        document_id, "news_article", %w(news_story press_release), 2, 10
      )
      whitehall_document_list = whitehall_adapter.document_list(
        document_id, "news_article", %w(news_story press_release)
      )

      whitehall_document_list.next
      expect(first_page).to have_been_requested

      whitehall_document_list.next
      expect(second_page).to have_been_requested

      expect { whitehall_document_list.next }.to raise_error(StopIteration)
    end
  end

  describe "#document_export" do
    let(:whitehall_export) { build(:whitehall_export_document) }

    before do
      stub_request(:get, "#{whitehall_host}/government/admin/export/document/123")
        .to_return(status: 200, body: whitehall_export.to_json)
    end

    it "makes a GET request to whitehall" do
      expect(whitehall_adapter.document_export("123")).to have_requested(:get, "#{whitehall_host}/government/admin/export/document/123")
    end
  end

  describe "#lock_document" do
    let(:document_id) { "123" }
    let(:lock_endpoint) do
      "#{whitehall_host}/government/admin/export/document/#{document_id}/lock"
    end

    before { stub_request(:post, lock_endpoint) }

    it "makes a POST request to Whitehall admin export API lock endpoint" do
      expect(whitehall_adapter.lock_document(document_id))
        .to have_requested(:post, lock_endpoint)
    end
  end

  describe "#unlock_document" do
    let(:document_id) { "123" }
    let(:unlock_endpoint) do
      "#{whitehall_host}/government/admin/export/document/#{document_id}/unlock"
    end

    before { stub_request(:post, unlock_endpoint) }

    it "makes a POST request to Whitehall admin export API unlock endpoint" do
      expect(whitehall_adapter.unlock_document(document_id))
        .to have_requested(:post, unlock_endpoint)
    end
  end

  describe "#document_migrated" do
    let(:migrated_endpoint) do
      "#{whitehall_host}/government/admin/export/document/#{document_id}/migrated"
    end

    before { stub_request(:post, migrated_endpoint) }

    it "makes a POST request to Whitehall admin export API migrated endpoint" do
      expect(whitehall_adapter.document_migrated(document_id))
        .to have_requested(:post, migrated_endpoint)
    end
  end

  def stub_whitehall_has_document_index(lead_organisation, document_type, document_subtypes, page_number, items_on_page)
    whitehall_host = Plek.new.external_url_for("whitehall-admin")
    stub_request(:get, "#{whitehall_host}/government/admin/export/document").
      with(query: hash_including(
        lead_organisation: lead_organisation,
        type: document_type,
        subtypes: document_subtypes,
        page_count: "100",
        page_number: page_number.to_s,
      )).
      to_return(status: 200,
        body: build(:whitehall_export_index, documents: build_list(:whitehall_export_index_document, items_on_page)).to_json)
  end
end
