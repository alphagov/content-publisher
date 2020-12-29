if ENV["STUB_PUBLISHING_API"] == "true"
  ENV["PLEK_SERVICE_PUBLISHING_API_URI"] ||= "http://localhost:#{ENV.fetch("PORT", 80)}"
end
