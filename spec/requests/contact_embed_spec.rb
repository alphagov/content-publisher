# frozen_string_literal: true

RSpec.describe "Contact Embed" do
  let(:edition) do
    body_field = build(:field, id: "body", type: "govspeak")
    document_type = build(:document_type, contents: [body_field])
    create(:edition, document_type_id: document_type.id)
  end
  let(:organisation) do
    {
      "content_id" => SecureRandom.uuid,
      "internal_name" => "Organisation",
    }
  end

  let(:contact) do
    {
      "content_id" => SecureRandom.uuid,
      "title" => "Contact",
      "links" => { "organisations" => [organisation["content_id"]] },
    }
  end

  before do
    stub_publishing_api_get_editions([contact], Contacts::EDITION_PARAMS)
    stub_publishing_api_has_linkables([organisation],
                                      document_type: "organisation")
  end

  describe "GET /documents/:document/contact-embed" do
    it "returns a successful response" do
      get contact_embed_path(edition.document)

      expect(response).to have_http_status(:ok)
    end

    it "renders a service unavailable response when the Publishing API is down" do
      stub_publishing_api_isnt_available
      get contact_embed_path(edition.document)

      expect(response).to have_http_status(:service_unavailable)
      expect(response.body).to have_content(I18n.t!("contact_embed.new.api_down"))
    end
  end

  describe "POST /documents/:document/contact-embed" do
    it "returns just the embed code in a model context" do
      post contact_embed_path(edition.document),
           params: { contact_id: contact["content_id"] },
           headers: { "Content-Publisher-Rendering-Context" => "modal" }

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/plain")
      expect(response.body)
        .to eq("[Contact: #{contact['content_id']}]")
    end

    it "shows the contact details outside a modal context" do
      post contact_embed_path(edition.document),
           params: { contact_id: contact["content_id"] }

      expect(response).to have_http_status(:ok)
      expect(response.body)
        .to have_content(contact["title"])
        .and have_content("[Contact: #{contact['content_id']}]")
    end

    it "renders a requirement issue with an unprocessable response when a contact is not selected" do
      post contact_embed_path(edition.document),
           params: { contact_id: nil }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body)
        .to have_content(I18n.t!("requirements.contact_embed.blank.form_message"))
    end

    it "renders a service unavailable response when the Publishing API is down" do
      stub_publishing_api_isnt_available
      post contact_embed_path(edition.document),
           params: { contact_id: nil }

      expect(response).to have_http_status(:service_unavailable)
      expect(response.body).to have_content(I18n.t!("contact_embed.new.api_down"))
    end
  end
end
