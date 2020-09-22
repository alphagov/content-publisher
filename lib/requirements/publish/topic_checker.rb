class Requirements::Publish::TopicChecker < Requirements::Checker
  attr_reader :edition

  def initialize(edition, **)
    @edition = edition
  end

  def check
    if edition.document_type.topics && edition.topics.none?
      issues.create(:topics, :none)
    end
  end
end
