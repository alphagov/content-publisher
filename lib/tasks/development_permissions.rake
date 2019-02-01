# frozen_string_literal: true

desc "Set development permissions on the mock User GDS-SSO uses"
task development_permissions: :environment do
  raise "Setting development permissions outside dev environment" unless Rails.env.development?

  user = User.first || User.create!(name: "publisher")
  permissions = (user.permissions + [User::PRE_RELEASE_FEATURES_PERMISSION,
                                     User::DEBUG_PERMISSION,
                                     User::MANAGING_EDITOR_PERMISSION]).uniq

  user.update_attribute(:permissions, permissions)
  puts "User permissions are now #{permissions.to_sentence}"
end
