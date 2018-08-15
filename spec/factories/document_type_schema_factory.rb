# frozen_string_literal: true

FactoryBot.define do
  factory :document_type_schema do
    supertype { "not-sure" }
    id { SecureRandom.hex(4) }
    document_type { SecureRandom.alphanumeric(8) }
    contents { [] }
    associations { [] }

    transient do
      translations do
        {
          formats: {
            associations: Hash[associations.map { |schema|
              [schema["id"], {
                label: SecureRandom.alphanumeric(8)
              }]
            }],
            document_types: {
              id => {
                label: id,
                guidance: {
                  title: {
                    title: SecureRandom.alphanumeric(8),
                    body: SecureRandom.alphanumeric(8)
                  },
                  summary: {
                    title: SecureRandom.alphanumeric(8),
                    body: SecureRandom.alphanumeric(8)
                  }
                }.merge(Hash[contents.map { |schema|
                  [schema["id"], {
                    title: SecureRandom.alphanumeric(8),
                    body: SecureRandom.alphanumeric(8)
                  }]
                }])
              }
            }
          }
        }
      end
    end

    initialize_with do
      I18n.backend.store_translations :en, translations
      DocumentTypeSchema.create(attributes.stringify_keys)
    end
  end
end
