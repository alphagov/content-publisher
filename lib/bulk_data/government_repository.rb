# frozen_string_literal: true

module BulkData
  class GovernmentRepository
    CACHE_KEY = "government-v1"

    def find(content_id)
      government = all.find { |g| g.content_id == content_id }
      government || (raise "Government #{content_id} not found")
    end

    def for_date(date)
      all.find { |g| g.covers?(date) } if date
    end

    def current
      all.find(&:current?)
    end

    def past
      all.reject(&:current?)
    end

    def all
      @all ||= Cache.read(CACHE_KEY)
                    .map { |data| Government.new(data) }
                    .sort_by(&:started_on)
    rescue Cache::NoEntryError
      PopulateBulkDataJob.perform_later
      raise LocalDataUnavailableError
    end

    def populate_cache(older_than: nil)
      return if older_than && Cache.written_after?(CACHE_KEY, older_than)

      data = GdsApi.publishing_api_v2
                   .get_paged_editions(document_types: %w[government],
                                       fields: %w[content_id locale title details],
                                       states: %w[published],
                                       locale: "en",
                                       per_page: 1000)
                   .inject([]) { |memo, page| memo + page["results"] }

      @all = nil
      Cache.write(CACHE_KEY, data)
    rescue GdsApi::BaseError
      raise RemoteDataUnavailableError
    end
  end
end
