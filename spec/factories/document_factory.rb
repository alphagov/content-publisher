# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    content_id { SecureRandom.uuid }
    locale { I18n.available_locales.sample }
    title { SecureRandom.alphanumeric(8) }
    base_path { title ? "#{DocumentTypeSchema.find(document_type).path_prefix}/#{title.parameterize}" : nil }
    document_type { DocumentTypeSchema.all.reject(&:managed_elsewhere).sample.id }

    trait :with_body_in_schema do
      document_type do
        DocumentTypeSchema.all.select { |schema| schema.contents.any? { |field| field.id == "body" } }.sample.id
      end
    end

    trait :with_associations do
      document_type do
        DocumentTypeSchema.all.select { |schema| schema.associations.any? }.sample.id
      end
    end
  end
end
