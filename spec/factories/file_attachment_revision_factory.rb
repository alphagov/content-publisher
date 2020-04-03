FactoryBot.define do
  factory :file_attachment_revision, class: "FileAttachment::Revision" do
    association :file_attachment, factory: :file_attachment
    association :created_by, factory: :user

    transient do
      filename { SecureRandom.hex(8) }
      number_of_pages { nil }
      isbn { nil }
      unique_reference { nil }
      fixture { "text-file-74bytes.txt" }
      title { SecureRandom.hex(8) }
      asset { nil }
      official_document_type { nil }
      paper_number { nil }
    end

    after(:build) do |revision, evaluator|
      unless revision.blob_revision
        revision.blob_revision = evaluator.association(
          :file_attachment_blob_revision,
          filename: evaluator.filename,
          number_of_pages: evaluator.number_of_pages,
          fixture: evaluator.fixture,
          asset: evaluator.asset,
        )
      end

      unless revision.metadata_revision
        revision.metadata_revision = evaluator.association(
          :file_attachment_metadata_revision,
          title: evaluator.title,
          isbn: evaluator.isbn,
          unique_reference: evaluator.unique_reference,
          official_document_type: evaluator.official_document_type,
          paper_number: evaluator.paper_number,
        )
      end
    end

    trait :on_asset_manager do
      transient {
        state { :draft }
      }

      after(:build) do |revision, evaluator|
        revision.blob_revision = evaluator.association(
          :file_attachment_blob_revision,
          :on_asset_manager,
          filename: evaluator.filename,
          number_of_pages: evaluator.number_of_pages,
          fixture: evaluator.fixture,
          state: evaluator.state,
          asset: evaluator.asset,
        )

        revision.metadata_revision = evaluator.association(
          :file_attachment_metadata_revision,
          title: evaluator.title,
          isbn: evaluator.isbn,
          unique_reference: evaluator.unique_reference,
          official_document_type: evaluator.official_document_type,
          paper_number: evaluator.paper_number,
        )
      end
    end
  end
end
