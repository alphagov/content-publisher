require "json"

namespace :export do
  desc "Export a specific live document and its assets, by its content ID"
  task :live_document_and_assets, %i[content_id output_file] => :environment do |_, args|
    document = Document.find_by(content_id: args[:content_id])
    hash = WhitehallMigration::DocumentExport.export_to_hash(document)

    if args[:output_file]
      File.write(args[:output_file], JSON.pretty_generate(hash))
    else
      pp hash
    end
  end

  desc "Export all live documents and assets"
  task :live_documents_and_assets, %i[output_directory] => :environment do |_, args|
    documents = WhitehallMigration::DocumentExport.exportable_documents

    puts "Exporting #{documents.count} live editions"

    documents.each do |document|
      hash = WhitehallMigration::DocumentExport.export_to_hash(document)

      if args[:output_directory]
        File.write("#{args[:output_directory]}/#{hash[:base_path].split('/').last}.json", JSON.pretty_generate(hash))
      else
        pp hash
      end
    end
  end
end
