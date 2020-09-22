class Requirements::Form::AccessLimitChecker < Requirements::Checker
  attr_reader :edition, :user

  def initialize(edition, user, **)
    @edition = edition
    @user = user
  end

  def check
    return if edition.access_limit.nil?

    if user.organisation_content_id.blank?
      issues.create(:access_limit, :user_has_no_org)
      return
    end

    if edition.primary_publishing_organisation_id.blank?
      issues.create(:access_limit, :no_primary_org)
      return
    end

    if user_is_not_in_access_limit_orgs?
      issues.create(:access_limit, :not_in_orgs)
    end
  end

private

  def user_is_not_in_access_limit_orgs?
    edition.access_limit_organisation_ids
      .exclude?(user.organisation_content_id)
  end
end
