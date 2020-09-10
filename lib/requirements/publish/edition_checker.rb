class Requirements::Publish::EditionChecker < Requirements::Checker
  attr_reader :edition, :rescue_api_errors

  CHECKERS = [
    Requirements::Publish::FileAttachmentsChecker,
    Requirements::Publish::ContentChecker,
    Requirements::Publish::TopicChecker,
  ].freeze

  def initialize(edition, rescue_api_errors: false, **)
    @edition = edition
    @rescue_api_errors = rescue_api_errors
  end

  def check
    CHECKERS.each do |checker|
      issues.push(*checker.call(edition))
    rescue GdsApi::BaseError => e
      GovukError.notify(e) if rescue_api_errors
      raise unless rescue_api_errors
    end
  end
end
