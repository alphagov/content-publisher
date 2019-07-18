module Formats
  class BodyField < Field
    def update(params, updater)
      contents = updater.revision.contents
      contents[:body] = params.permit(:body).fetch(:body)
      updater.assign(contents: contents)
    end

    def inject(edition, payload)
      payload["details"]["body"] = edition.contents["body"]
    end
  end
end
