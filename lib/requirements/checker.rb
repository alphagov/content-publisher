class Requirements::Checker
  private_class_method :new

  def self.call(*args, **kwargs)
    instance = new(*args, **kwargs)
    instance.check
    instance.issues
  end

  def issues
    @issues ||= Requirements::CheckerIssues.new
  end
end
