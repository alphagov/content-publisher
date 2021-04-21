module Healthcheck
  class ActiveStorage
    def name
      :active_storage
    end

    def status
      ::ActiveStorage::Blob.service.exist?("does-not-exist")
      :ok
    rescue StandardError
      :warning
    end

    def to_hash
      {
        status: status,
      }
    end
  end
end
