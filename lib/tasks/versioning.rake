# frozen_string_literal: true

namespace :versioning do
  task demo: :environment do
    Document.transaction do
      content_id = SecureRandom.uuid
      user = User.first

      # create a document with a current revision
      document = Versioning::Document.create!(content_id: content_id,
                                              locale: "en",
                                              created_by: user,
                                              document_type_id: "news_story")

      revision = create_revision({ title: "Initial title" }, document, user)

      current_edition = create_edition(
        { number: document.next_edition_number, document: document, current: true },
        revision,
        user,
      )

      # add an image
      image = create_image("image.jpg")
      second_revision = create_revision({}, document, user, revision, [image.id])
      update_edition_revision(current_edition, second_revision)

      puts "Created Versioning::Document with id: #{document.id}"
    end
  end

  def create_revision(data, document, user, previous_revision = nil, image_ids = nil)
    revision = previous_revision&.dup || Versioning::Revision.new
    revision.tap do |r|
      preset_data = { created_by: user, document: document }
      r.assign_attributes(data.merge(preset_data))
      r.document = document
      r.image_ids = image_ids || previous_revision&.image_ids || []
      r.save!
    end
  end

  def create_edition(data, revision, user)
    Versioning::Edition.new.tap do |edition|
      edition.update!(
        data.merge(current_revision: revision, created_by: user),
      )
    end
  end

  def update_edition_revision(edition, revision)
    edition.tap { |e| e.update!(current_revision: revision) }
  end

  def create_image(filename)
    file = File.open(Rails.root.join("spec", "fixtures", "files", "960x640.jpg"))
    blob = ActiveStorage::Blob.create_after_upload!(io: file,
                                                    filename: filename,
                                                    content_type: "image/jpg")
    Versioning::Image.create!(blob: blob,
                              filename: filename,
                              width: 960,
                              height: 640,
                              crop_x: 0,
                              crop_y: 0,
                              crop_width: 960,
                              crop_height: 640,
                              alt_text: "Image")
  end
end
