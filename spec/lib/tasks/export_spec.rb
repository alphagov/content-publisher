RSpec.describe "Export tasks" do
  include ActiveJob::TestHelper

  describe "export:live_document_and_assets" do
    before do
      Rake::Task["export:live_document_and_assets"].reenable
    end

    it "calls WhitehallMigration::DocumentExport.export_to_hash with correct arguments" do
      document = create(:document, :with_live_edition)
      allow(WhitehallMigration::DocumentExport).to receive(:export_to_hash)
      Rake::Task["export:live_document_and_assets"].invoke(document.content_id)
      expect(WhitehallMigration::DocumentExport).to have_received(:export_to_hash).with(document)
    end

    it "pretty-prints the result to STDOUT if no output_file is specified" do
      document = create(:document, :with_live_edition)
      allow(WhitehallMigration::DocumentExport).to receive(:export_to_hash).and_return({ foo: "bar" })
      expect { Rake::Task["export:live_document_and_assets"].invoke(document.content_id) }.to output("{:foo=>\"bar\"}\n").to_stdout
    end

    it "writes the result as JSON to the given output_file if specified" do
      document = create(:document, :with_live_edition)
      allow(WhitehallMigration::DocumentExport).to receive(:export_to_hash).and_return({ foo: "bar", baz: "qux" })

      output_file = Tempfile.new("export")
      Rake::Task["export:live_document_and_assets"].invoke(document.content_id, output_file.path)

      expected = <<~JSON
        {
          "foo": "bar",
          "baz": "qux"
        }
      JSON
      expect(File.read(output_file.path)).to match(expected.strip)
    end
  end

  describe "export:live_documents_and_assets" do
    before do
      allow($stdout).to receive(:puts) # suppress output for cleanliness
      Rake::Task["export:live_documents_and_assets"].reenable
      Document.find_each(&:destroy) # Clean slate
      allow(WhitehallMigration::DocumentExport).to receive(:exportable_documents).and_return(documents)
    end

    let(:documents) do
      [
        create(:document, :with_live_edition),
        create(:document, :with_live_edition),
        create(:document, :with_live_edition),
      ]
    end

    it "lists how many documents it is about to export" do
      expect { Rake::Task["export:live_documents_and_assets"].invoke }.to output(/^Exporting 3 live editions/).to_stdout
    end

    it "calls WhitehallMigration::DocumentExport.export_to_hash with correct arguments" do
      allow(WhitehallMigration::DocumentExport).to receive(:export_to_hash)
      Rake::Task["export:live_documents_and_assets"].invoke
      expect(WhitehallMigration::DocumentExport).to have_received(:export_to_hash).with(documents[0])
      expect(WhitehallMigration::DocumentExport).to have_received(:export_to_hash).with(documents[1])
      expect(WhitehallMigration::DocumentExport).to have_received(:export_to_hash).with(documents[2])
    end

    it "pretty-prints the result to STDOUT if no output_directory is specified" do
      allow(WhitehallMigration::DocumentExport).to receive(:export_to_hash).and_return({ foo: "bar" })
      expect { Rake::Task["export:live_documents_and_assets"].invoke }.to output(/{:foo=>"bar"}\n{:foo=>"bar"}\n{:foo=>"bar"}\n$/).to_stdout
    end

    it "writes the result as JSON files to the given output_directory if specified" do
      allow(WhitehallMigration::DocumentExport).to receive(:export_to_hash) do |document|
        { base_path: "/news/example-path-#{document.id}" }
      end
      output_directory = Dir.mktmpdir
      Rake::Task["export:live_documents_and_assets"].invoke(output_directory)

      expected_files = documents.map { |doc| "#{output_directory}/example-path-#{doc.id}.json" }
      actual_files = Dir.glob("#{output_directory}/*.json").sort
      expect(actual_files).to match_array(expected_files)
    end
  end
end
