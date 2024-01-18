class ResyncDocumentJob < ApplicationJob
  retry_on(
    GdsApi::BaseError,
    attempts: 5,
    wait: :polynomially_longer,
  ) { |_job, error| GovukError.notify(error) }

  def perform(document)
    ResyncDocumentService.call(document)
  end
end
