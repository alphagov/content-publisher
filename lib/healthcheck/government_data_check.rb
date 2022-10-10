module Healthcheck
  class GovernmentDataCheck
    attr_reader :government_repo

    def initialize
      @government_repo = BulkData::GovernmentRepository.new
    end

    def name
      :government_data_check
    end

    def status
      return :critical unless government_repo.cache_populated?
      return :warning if government_repo.cache_age > 6.hours

      :ok
    end

    def message
      return "No government data availible" if status == :critical

      warning_details_content if status == :warning
    end

    def enabled?
      true
    end

    def to_hash
      {
        status:,
        message:,
      }
    end

  private

    def warning_details_content
      data_age = government_repo.cache_age.to_i
      "Government data not refreshed in #{data_age / 1.hour} hours."
    end
  end
end
