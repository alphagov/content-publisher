# frozen_string_literal: true

module BulkDataHelper
  def populate_default_government_bulk_data
    current_government = build(:government)
    past_government = build(:government, :past)

    populate_government_bulk_data(current_government, past_government)
  end

  def populate_government_bulk_data(*governments)
    BulkData::Cache.write(BulkData::GovernmentRepository::CACHE_KEY,
                          governments.map(&:to_h))
  end

  def current_government
    BulkData::GovernmentRepository.new.current
  end

  def past_government
    BulkData::GovernmentRepository.new.past&.first
  end
end
