# config/initializers/govuk_publishing_components.rb
GovukPublishingComponents.configure do |c|
  c.component_guide_title = "Content Publisher"
  c.application_print_stylesheet = nil

  c.application_stylesheet = "govuk_publishing_components/admin_styles"
  c.application_javascript = nil
end
