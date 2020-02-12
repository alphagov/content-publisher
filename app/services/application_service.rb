class ApplicationService
  private_class_method :new

  def self.call(*args)
    new(*args).call
  end
end
