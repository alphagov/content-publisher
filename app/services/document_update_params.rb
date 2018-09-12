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
    contents_params = document.document_type_schema.contents.map(&:id)

    document_params = params.require(:document).permit(:update_type,
                                                       :change_note,
                                                       :title,
                                                       :summary,
                                                       contents: contents_params)

    path_title = document_params[:title].squish[0...TITLE_SLUG_MAX_LENGTH]

    document_params[:base_path] = PathGeneratorService.new.path(document, path_title)
    document_params[:title] = document_params[:title].squish[0...TITLE_MAX_LENGTH]
    document_params[:summary] = document_params[:summary].squish[0...SUMMARY_MAX_LENGTH]
    document_params
  end
end
