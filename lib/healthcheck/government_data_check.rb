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
      return GovukHealthcheck::CRITICAL unless government_repo.cache_populated?
      return GovukHealthcheck::WARNING if government_repo.cache_age > 6.hours

      GovukHealthcheck::OK
    end

    def message
      return "No government data availible" if status == GovukHealthcheck::CRITICAL

      warning_details_content if status == GovukHealthcheck::WARNING
    end

    def enabled?
      true
    end

  private

    def warning_details_content
      data_age = government_repo.cache_age.to_i
      "Government data not refreshed in #{data_age / 1.hour} hours."
    end
  end
end
