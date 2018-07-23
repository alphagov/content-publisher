# frozen_string_literal: true

class NewDocumentController < ApplicationController
  def choose_supertype
    @supertype_radio_options = SupertypeThing.new.options
  end

  def choose_document_type
    if params[:supertype] == SupertypeThing::NOT_SURE_OPTION.fetch(:value)
      redirect_to guidance_path
      return
    end

    @document_types = YAML.load_file("app/formats/document_types.yml").select { |s| s["supertype"] == params[:supertype] }
  end

  def create
    document_type_schema = YAML.load_file("app/formats/document_types.yml").find { |s| s["document_type"] == params[:document_type] }

    if document_type_schema["managed_elsewhere"]
      redirect_to document_type_schema["managed_elsewhere"]
      return
    end

    document = Document.create!(
      content_id: SecureRandom.uuid,
      locale: "en",
      document_type: params[:document_type],
    )

    redirect_to edit_document_path(document)
  end

  # TODO: This class has an intentionally silly name, because we don't know if there
  # will be classes like this and how to organise these.
  class SupertypeThing
    NOT_SURE_OPTION = {
      value: "not-sure",
      text: "I'm not sure this should be on GOV.UK",
      hint_text: "View this guide to what should go on GOV.UK and where else we can publish content.",
      bold: true
    }.freeze

    def options
      supertype_options + [NOT_SURE_OPTION]
    end

  private

    def supertype_options
      YAML.load_file("app/formats/supertypes.yml").map do |supertype|
        {
          value: supertype["id"],
          text: supertype["label"],
          hint_text: supertype["description"],
          bold: true,
        }
      end
    end
  end
end
