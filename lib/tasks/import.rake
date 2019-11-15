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
    importer = ::WhitehallImporter.new(whitehall_export)
    begin
      importer.import
      importer.update_state("completed")
    rescue StandardError => e
      importer.log_error(e.message)
      importer.update_state("failed")
    end
  end
end
