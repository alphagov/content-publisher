# frozen_string_literal: true

RSpec.describe "Political documents tasks" do
  describe "political_status_by_organisation" do
    let(:organisation1) { { "content_id" => SecureRandom.uuid, "internal_name" => "Org 1" } }
    let(:organisation2) { { "content_id" => SecureRandom.uuid, "internal_name" => "Org 2" } }
    let(:csv_headers) { ["Public URL", "Admin URL", "Title", "Document type", "Political", "Summary"] }

    before :each do
      Rake::Task["csv_report:political_status_by_organisation"].reenable
      stub_publishing_api_has_linkables([organisation1, organisation2], document_type: "organisation")
    end

    it "can output political status" do
      create(:edition, :published, tags: { primary_publishing_organisation: [organisation1["content_id"]] })

      csv_file = StringIO.new
      expected_content = [
        "https://gov.uk#{Edition.first.base_path}",
        "https://content-publisher.publishing.service.gov.uk/documents/#{Edition.first.content_id}:#{Edition.first.locale}",
        Edition.first.title,
        Edition.first.document_type.id.humanize,
        "No",
        Edition.first.summary,
      ]

      expect(CSV).to receive(:open).with(
        Rails.root.join("tmp/org-1-political-status.csv"), "w",
        headers: csv_headers,
        write_headers: true
      ).and_yield(csv_file)

      expect(csv_file).to receive(:<<).with(expected_content)
      expect($stdout).to receive(:puts).with("Report available at #{Rails.root}/tmp/#{organisation1['internal_name'].parameterize}-political-status.csv")

      Rake::Task["csv_report:political_status_by_organisation"].invoke
    end

    it "creates a CSV per organisation" do
      create(:edition, :published, tags: { primary_publishing_organisation: [organisation1["content_id"]] })
      create(:edition, :published, tags: { primary_publishing_organisation: [organisation2["content_id"]] })

      expect(CSV).to receive(:open).with(
        Rails.root.join("tmp/org-1-political-status.csv"), "w",
        headers: csv_headers,
        write_headers: true
      )
      expect(CSV).to receive(:open).with(
        Rails.root.join("tmp/org-2-political-status.csv"), "w",
        headers: csv_headers,
        write_headers: true
      )
      expect($stdout).to receive(:puts).with("Report available at #{Rails.root}/tmp/#{organisation1['internal_name'].parameterize}-political-status.csv")
      expect($stdout).to receive(:puts).with("Report available at #{Rails.root}/tmp/#{organisation2['internal_name'].parameterize}-political-status.csv")

      Rake::Task["csv_report:political_status_by_organisation"].invoke
    end

    it "ignores draft content" do
      create(:edition, tags: { primary_publishing_organisation: [organisation1["content_id"]] })

      expect(CSV).not_to receive(:open)

      Rake::Task["csv_report:political_status_by_organisation"].invoke
    end
  end
end
