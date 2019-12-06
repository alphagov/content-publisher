# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { "John Smith" }
    uid { SecureRandom.uuid }
    email { "someone@example.com" }
    transient do
      managing_editor { false }
      manage_live_history_mode { false }
    end

    permissions do
      [User::PRE_RELEASE_FEATURES_PERMISSION].tap do |p|
        p << User::MANAGING_EDITOR_PERMISSION if managing_editor
        p << User::MANAGE_LIVE_HISTORY_MODE if manage_live_history_mode
      end
    end
  end
end
