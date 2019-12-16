# frozen_string_literal: true

require "gds_api/json_client"

namespace :import do
  desc "Import a single document from Whitehall Publisher using Whitehall's internal document ID e.g. import:whitehall[123]"
  task :whitehall, [:document_id] => :environment do |_, args|
    host = Plek.new.external_url_for("whitehall-admin")
    endpoint = "#{host}/government/admin/export/document/#{args.document_id}"
    options = {
      "bearer_token": ENV["WHITEHALL_BEARER_TOKEN"] || "example",
    }
    client = GdsApi::JsonClient.new(options)
    response = client.get_json(endpoint)
    whitehall_export = response.to_hash
    import = WhitehallImporter.import(whitehall_export)

    if import.import_failed?
      puts "Import failed"
      puts "Error: #{import.error_log}"
      abort
    else
      document = Document.find_by(content_id: import.content_id)
      WhitehallImporter.sync(document)
    end
  end
end
