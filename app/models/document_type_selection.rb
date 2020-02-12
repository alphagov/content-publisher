class DocumentTypeSelection
  include InitializeWithHash

  attr_reader :id, :options

  def self.find(id)
    item = all.find { |document_type_selection| document_type_selection.id == id }
    item || (raise NotFoundError, "Document type selection #{id} not found")
  end

  def self.all
    @all ||= begin
      hashes = YAML.load_file(Rails.root.join("config/document_type_selections.yml"))

      hashes.map do |hash|
        hash["options"].map! do |option|
          Option.new(option)
        end
        new(hash)
      end
    end
  end

  def parent
    self.class.all.find do |document_type_selection|
      document_type_selection.options.map(&:id).include?(id)
    end
  end

  class NotFoundError < RuntimeError; end
end
