# frozen_string_literal: true

user = User.find_or_create_by!(name: "publisher")

gds_organisation_content_id = "af07d5a5-df63-4ddc-9383-6a666845ebe9"

permissions = [User::PRE_RELEASE_FEATURES_PERMISSION]
permissions << User::DEBUG_PERMISSION if Rails.env.development?

user.update!(permissions: permissions,
             organisation_content_id: gds_organisation_content_id,
             email: "someone-else@example.com")
