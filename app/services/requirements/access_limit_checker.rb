# frozen_string_literal: true

module Requirements
  class AccessLimitChecker
    attr_reader :edition, :user

    def initialize(edition, user)
      @edition = edition
      @user = user
    end

    def pre_update_issues
      issues = []

      if edition.access_limit.nil?
        return CheckerIssues.new([])
      end

      if edition.primary_publishing_organisation_id.blank?
        issues << Issue.new(:access_limit, :no_primary_org)
        return CheckerIssues.new(issues)
      end

      if edition.access_limit.primary_organisation? &&
          user_is_not_in_primary_org?
        issues << Issue.new(:access_limit, :not_in_orgs)
      end

      if edition.access_limit.tagged_organisations? &&
          user_is_not_in_any_org?
        issues << Issue.new(:access_limit, :not_in_orgs)
      end

      CheckerIssues.new(issues)
    end

  private

    def user_is_not_in_primary_org?
      edition.primary_publishing_organisation_id !=
        user.organisation_content_id
    end

    def user_is_not_in_any_org?
      user_is_not_in_primary_org? &&
        edition.organisations.exclude?(user.organisation_content_id)
    end
  end
end
