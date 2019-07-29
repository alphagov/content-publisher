# frozen_string_literal: true

module Requirements
  class AccessLimitChecker
    attr_reader :edition, :user

    def initialize(edition, user)
      @edition = edition
      @user = user
    end

    def pre_update_issues
      issues = CheckerIssues.new
      return issues if edition.access_limit.nil?

      if user.organisation_content_id.blank?
        issues << Issue.new(:access_limit, :user_has_no_org)
        return issues
      end

      if edition.primary_publishing_organisation_id.blank?
        issues << Issue.new(:access_limit, :no_primary_org)
        return issues
      end

      if user_is_not_in_access_limit_orgs?
        issues << Issue.new(:access_limit, :not_in_orgs)
      end

      issues
    end

  private

    def user_is_not_in_access_limit_orgs?
      edition.access_limit.organisation_ids
        .exclude?(user.organisation_content_id)
    end
  end
end
