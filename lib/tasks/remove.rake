namespace :remove do
  desc "Remove a document with a gone on GOV.UK e.g. remove:gone['a-content-id']"
  task :gone, [:content_id] => :environment do |_, args|
    raise "Missing content_id parameter" unless args.content_id

    explanatory_note = ENV["NOTE"]
    alternative_url = ENV["URL"]
    locale = ENV["LOCALE"] || "en"
    user = User.find_by!(email: ENV["USER_EMAIL"]) if ENV["USER_EMAIL"]

    document = Document.find_by!(content_id: args.content_id, locale:)
    raise "Document must have a published version before it can be removed" unless document.live_edition

    removal = Removal.new(explanatory_note:,
                          alternative_url:)

    RemoveDocumentService.call(document.live_edition, removal, user:)
  end

  desc "Remove a document with a redirect on GOV.UK e.g. remove:redirect['a-content-id'] URL='/redirect-to-here'"
  task :redirect, [:content_id] => :environment do |_, args|
    raise "Missing content_id parameter" unless args.content_id
    raise "Missing URL value" if ENV["URL"].blank?

    explanatory_note = ENV["NOTE"]
    redirect_url = ENV["URL"]
    locale = ENV["LOCALE"] || "en"
    user = User.find_by!(email: ENV["USER_EMAIL"]) if ENV["USER_EMAIL"]

    document = Document.find_by!(content_id: args.content_id, locale:)
    raise "Document must have a published version before it can be redirected" unless document.live_edition

    removal = Removal.new(redirect: true,
                          explanatory_note:,
                          alternative_url: redirect_url)

    RemoveDocumentService.call(document.live_edition, removal, user:)
  end
end
