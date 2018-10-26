# frozen_string_literal: true

user = User.find_or_create_by!(name: "publisher")
user.update_attribute(:permissions, [User::PRE_RELEASE_FEATURES_PERMISSION])
