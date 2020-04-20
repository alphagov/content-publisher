class Requirements::Checker
  private_class_method :new

  def self.call(*args)
    new(*args).issues
  end
end
