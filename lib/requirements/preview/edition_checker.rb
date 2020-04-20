class Requirements::Preview::EditionChecker < Requirements::Checker
  attr_reader :edition

  CHECKERS = [
    Requirements::Preview::ContentChecker,
    Requirements::Preview::TagsChecker,
    Requirements::Preview::ImagesChecker,
  ].freeze

  def initialize(edition)
    @edition = edition
  end

  def issues
    issues = Requirements::CheckerIssues.new

    CHECKERS.each do |checker|
      issues += checker.call(edition)
    end

    issues
  end
end
