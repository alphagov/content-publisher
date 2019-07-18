module Formats
  class SummaryField < Field
    def update(params, updater)
      summary = params.permit(:summary).fetch(:summary)&.strip
      updater.assign(summary: summary)
    end

    def inject(edition, payload)
      payload["description"] = edition.summary
    end
  end
end
