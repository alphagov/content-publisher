# frozen_string_literal: true

class DocumentUpdateParams
  TITLE_SLUG_MAX_LENGTH = 150
  TITLE_MAX_LENGTH = 300
  SUMMARY_MAX_LENGTH = 600

  attr_reader :document

  def initialize(document)
    @document = document
  end

  def update_params(params)
    path_title = params[:document][:title].squish[0...TITLE_SLUG_MAX_LENGTH]
    base_path = PathGeneratorService.new.path(document, path_title)

    title = params[:document][:title].squish[0...TITLE_MAX_LENGTH]
    summary = params[:document][:summary].squish[0...SUMMARY_MAX_LENGTH]

    contents_params = document.document_type_schema.contents.map(&:id)

    params.require(:document).permit(:update_type, :change_note, contents: contents_params)
      .merge(base_path: base_path, title: title, summary: summary)
  end
end
