# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

# Fix for Rack::Maintenance gem that still call File.exists? (removed in Ruby 3.2)
unless File.respond_to?(:exists?)
  def File.exists?(path)
    File.exist?(path)
  end
end

use Rack::Maintenance,
    file: Rails.root.join("public", "maintenance.html")

run Rails.application
Rails.application.load_server
