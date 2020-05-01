class Requirements::Checker
  private_class_method :new

  def self.call(*args)
    instance = new(*args)
    instance.check
    instance.issues
  end

  def issues
    @issues ||= Requirements::CheckerIssues.new
  end
end
