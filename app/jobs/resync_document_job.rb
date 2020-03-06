class ResyncDocumentJob < ApplicationJob
  def perform(document)
    ResyncDocumentService.call(document)
  end
end
