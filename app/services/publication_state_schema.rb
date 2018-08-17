# frozen_string_literal: true

class PublicationStateSchema
  attr_accessor :id, :label, :description

  def initialize(params)
    @id = params["id"]
    @label = params["label"]
    @description = params["description"]
  end

  def self.all
    @all ||= begin
      states = YAML.load_file("app/states/publication_states.yml")
      states.map { |data| PublicationStateSchema.new(data) }
    end
  end

  def self.find(publication_state_id)
    item = all.find { |schema| schema.id == publication_state_id }
    item || (raise RuntimeError, "Publication state #{publication_state_id} not found")
  end
end
