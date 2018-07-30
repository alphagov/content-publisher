class PublishingApiPayload
  PUBLISHING_APP = "content-publisher"

  def initialize(document)
    @document = document
  end

  def payload
    {
      base_path: document.base_path,
      title: document.title,
      locale: document.locale,
      description: document.summary,
      schema_name: document.document_type_schema.schema_name,
      document_type: document.document_type,
      publishing_app: PUBLISHING_APP,
      rendering_app: document.document_type_schema.rendering_app,
      details: document.contents.merge(government: {
                                         title: "Hey", slug: "what", current: true,
                                       },
                                       change_history: [{
                                         public_timestamp: Time.now.iso8601,
                                         note: "To support email alerts"
                                       }],
                                       political: false),
      routes: [
        { path: document.base_path, type: "exact" },
      ]
    }
  end

private

  attr_reader :document
end
