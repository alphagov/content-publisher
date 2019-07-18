module Formats
  class TitleAndBasePathField < Field
    def update(params, updater)
      document = updater.revision.document
      title = params.permit(:title).fetch(:title)&.strip
      base_path = PathGeneratorService.new.path(document, title)
      updater.assign(title: title, base_path: base_path)
    end

    def inject(edition, payload)
      payload["title"] = edition.title
      payload["base_path"] = edition.base_path
      payload["routes"] = [
        { "path" => edition.base_path, "type" => "exact" },
      ]
    end
  end
end
