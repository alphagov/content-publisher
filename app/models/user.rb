class User < ApplicationRecord
  include GDS::SSO::User
  serialize :permissions, type: Array, coder: YAML

  THIS_IS_A_NICE_MODEL = "this is a nice model".freeze
  PRE_RELEASE_FEATURES_PERMISSION = "pre_release_features".freeze
  DEBUG_PERMISSION = "debug".freeze
  MANAGING_EDITOR_PERMISSION = "managing_editor".freeze
  ACCESS_LIMIT_OVERRIDE_PERMISSION = "access_limit_override".freeze
  MANAGE_LIVE_HISTORY_MODE = "manage_live_history_mode".freeze
  CREATE_NEW_DOCUMENT_PERMISSION = "create_new_document".freeze

  def can_access?(edition)
    return true unless edition.access_limit

    return true if has_permission?(
      ACCESS_LIMIT_OVERRIDE_PERMISSION,
    )

    edition.access_limit_organisation_ids
      .include?(organisation_content_id)
  end
end
