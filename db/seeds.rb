# frozen_string_literal: true

user = User.find_or_create_by!(name: "publisher")

user.update!(permissions: [User::PRE_RELEASE_FEATURES_PERMISSION],
            organisation_content_id: SecureRandom.uuid)
