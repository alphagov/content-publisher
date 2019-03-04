if !Rails.env.production? && ENV["BYEBUG_PORT"]
  require "byebug/core"
  Byebug.start_server "localhost", ENV["BYEBUG_PORT"].to_i
end
