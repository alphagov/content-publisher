# frozen_string_literal: true

namespace :import do
  desc "Import a single document from Whitehall Publisher using Whitehall's internal document ID e.g. import:whitehall[123]"
  task :whitehall, [:document_id] => :environment do |_, args|
    document_id = args.document_id
    host = Plek.new.external_url_for("whitehall-admin")
    whitehall_export = JSON.parse(URI.parse("#{host}/government/admin/export/document/#{document_id}").open.read)
    importer = Tasks::WhitehallImporter.new(document_id, whitehall_export)
    begin
      importer.import
      importer.update_state("completed")
    rescue StandardError => e
      importer.log_error(e.message)
      importer.update_state("failed")
    end
  end
end
