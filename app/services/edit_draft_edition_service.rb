class EditDraftEditionService
  include Callable

  def initialize(edition, user, **attributes)
    @edition = edition
    @user = user
    @attributes = attributes
  end

  def call
    raise "cannot edit a live edition" if edition.live?

    edition.assign_attributes(extended_attributes)
    determine_political
    associate_with_government
    edition.add_edition_editor(user)
  end

private

  attr_reader :edition, :user, :attributes

  def extended_attributes
    result = attributes.merge(last_edited_by: user, last_edited_at: Time.zone.now)
    result[:revision_synced] = false if attributes.key?(:revision)
    result
  end

  def determine_political
    identifier = PoliticalEditionIdentifier.new(edition)
    edition.system_political = identifier.political?
  end

  def associate_with_government
    repository = BulkData::GovernmentRepository.new
    date = edition.public_first_published_at
    edition.government_id = repository.for_date(date)&.content_id
  end
end
