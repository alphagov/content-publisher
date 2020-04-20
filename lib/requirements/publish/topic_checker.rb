class Requirements::Publish::TopicChecker < Requirements::Checker
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def issues
    issues = Requirements::CheckerIssues.new

    if edition.document_type.topics && edition.topics.none?
      issues.create(:topics, :none)
    end

    issues
  end
end
