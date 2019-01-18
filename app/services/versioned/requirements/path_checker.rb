# frozen_string_literal: true

module Versioned
  module Requirements
    class PathChecker
      attr_reader :edition, :revision

      def initialize(edition, revision = nil)
        @edition = edition
        @revision = revision || edition.revision
      end

      def pre_preview_issues
        issues = []

        begin
          if edition.document_type.check_path_conflict && base_path_conflict?
            issues << ::Requirements::Issue.new(:title, :conflict)
          end
        rescue GdsApi::BaseError => e
          GovukError.notify(e)
        end

        ::Requirements::CheckerIssues.new(issues)
      end

    private

      def base_path_conflict?
        base_path_owner = GdsApi.publishing_api_v2.lookup_content_id(
          base_path: revision.base_path,
          with_drafts: true,
          exclude_document_types: [],
          exclude_unpublishing_types: [],
        )

        base_path_owner && base_path_owner != edition.content_id
      end
    end
  end
end
