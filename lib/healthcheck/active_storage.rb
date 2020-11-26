module Healthcheck
  class ActiveStorage
    def name
      :active_storage
    end

    def status
      ::ActiveStorage::Blob.service.exist?("does-not-exist")
      GovukHealthcheck::OK
    rescue StandardError
      GovukHealthcheck::WARNING
    end
  end
end
