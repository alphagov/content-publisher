# config/initializers/govuk_publishing_components.rb
GovukPublishingComponents.configure do |c|
  c.component_guide_title = "Content Publisher"
  c.application_print_stylesheet = nil

  c.application_stylesheet = "application"
  c.application_javascript = "application"
end
