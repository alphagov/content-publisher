class ApplicationService
  private_class_method :new

  def self.call(*args, **kwargs)
    new(*args, **kwargs).call
  end
end
