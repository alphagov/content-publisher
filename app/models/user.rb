# frozen_string_literal: true

class User < ApplicationRecord
  include GDS::SSO::User
  serialize :permissions, Array

  PRE_RELEASE_FEATURES_PERMISSION = "pre_release_features"
  DEBUG_PERMISSION = "debug"
  MANAGING_EDITOR_PERMISSION = "managing_editor"
  ACCESS_LIMIT_OVERRIDE_PERMISSION = "access_limit_override"

  def can_access?(edition)
    return true unless edition.access_limit

    return true if has_permission?(
      ACCESS_LIMIT_OVERRIDE_PERMISSION,
    )

    edition.access_limit_organisation_ids
      .include?(organisation_content_id)
  end
end
