# frozen_string_literal: true

namespace :versioning do
  task demo: :environment do
    Document.transaction do
      content_id = SecureRandom.uuid
      user = User.first

      # create a document with a current revision
      document = Versioned::Document.create!(content_id: content_id,
                                              locale: "en",
                                              created_by: user,
                                              document_type_id: "news_story",
                                              last_edited_by: user)

      revision = create_revision({ title: "Initial title" }, document, user)

      status = Versioned::EditionStatus.create!(created_by: user,
                                                 user_facing_state: :draft,
                                                 publishing_api_sync: :complete,
                                                 revision_at_creation: revision)

      current_edition = create_edition(
        { number: document.next_edition_number,
          document: document,
          current: true,
          status: status },
        revision,
        user,
      )

      # add an image
      image = create_image("image.jpg")
      second_revision = create_revision({}, document, user, revision, [image.id])
      update_edition_revision(current_edition, second_revision)

      puts "Created Versioned::Document with id: #{document.id}"
    end
  end

  def create_revision(data, document, user, previous_revision = nil, image_ids = nil)
    revision = previous_revision&.dup || Versioned::Revision.new
    revision.tap do |r|
      preset_data = { created_by: user, document: document }
      r.assign_attributes(data.merge(preset_data))
      r.image_ids = image_ids || previous_revision&.image_ids || []
      r.save!
    end
  end

  def create_edition(data, revision, user)
    data = data.merge(revision: revision, created_by: user, last_edited_by: user)
    Versioned::Edition.create!(data)
  end

  def update_edition_revision(edition, revision)
    edition.tap do |e|
      e.update!(revision: revision)
      e.update_last_edited_at(revision.created_by)
    end
  end

  def create_image(filename)
    file = File.open(Rails.root.join("spec", "fixtures", "files", "960x640.jpg"))
    blob = ActiveStorage::Blob.create_after_upload!(io: file,
                                                    filename: filename,
                                                    content_type: "image/jpg")
    Versioned::Image.create!(blob: blob,
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
