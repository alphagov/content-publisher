# frozen_string_literal: true

require "csv"

namespace :csv_report do
  desc "A CSV report of political documents published by organisations"
  task political_status_by_organisation: :environment do
    live_editions = Edition.where(live: true).joins(revision: :tags_revision)
    org_content_ids = live_editions.pluck(Arel.sql("tags_revisions.tags->'primary_publishing_organisation'->0")).uniq
    links = Linkables.new("organisation")

    organisations = org_content_ids.map { |id| links.by_content_id(id) }.compact

    organisations.each do |organisation|
      path = Rails.root.join("tmp", "#{organisation['internal_name'].parameterize}-political-status.csv")
      csv_headers = ["Public URL", "Admin URL", "Title", "Document type", "Political", "Summary"]

      CSV.open(path, "w", headers: csv_headers, write_headers: true) do |csv|
        editions_published_by_organisation = live_editions.merge(TagsRevision.primary_organisation_is(organisation["content_id"]))

        editions_published_by_organisation.each do |edition|
          csv << [
            "https://gov.uk#{edition.base_path}",
            "https://content-publisher.publishing.service.gov.uk/documents/#{edition.content_id}:#{edition.locale}",
            edition.title,
            edition.document_type.id.humanize,
            PoliticalEditionIdentifier.new(edition).political? ? "Yes" : "No",
            edition.summary,
          ]
        end
      end

      puts "Report available at #{path}"
    end
  end
end
