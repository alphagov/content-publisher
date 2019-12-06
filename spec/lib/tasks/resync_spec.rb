# frozen_string_literal: true

RSpec.describe "Resync tasks" do
  describe "resync:document" do
    it "resyncs a document" do
      document = create(:document)

      expect(ResyncService)
        .to receive(:call)
        .once
        .with(document)

      Rake::Task["resync:document"].invoke("#{document.content_id}:#{document.locale}")
    end
  end

  describe "resync:all" do
    it "resyncs all documents" do
      create_list(:document, 2)

      expect(ResyncService)
        .to receive(:call)
        .twice

      Rake::Task["resync:all"].invoke
    end
  end
end
