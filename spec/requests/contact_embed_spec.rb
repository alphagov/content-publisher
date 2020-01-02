# frozen_string_literal: true

RSpec.describe "Contact Embed" do
  let(:edition) do
    body_field = build(:field, id: "body", type: "govspeak")
    document_type = build(:document_type, contents: [body_field])
    create(:edition, document_type_id: document_type.id)
  end

  describe "GET /documents/:document/contact-embed" do
    it "renders a 503 response when the Publishing API is down" do
      stub_publishing_api_isnt_available
      get contact_embed_path(edition.document)

      expect(response.status).to eq(503)
      expect(response.body).to include(I18n.t!("contact_embed.new.api_down"))
    end
  end

  describe "POST /documents/:document/contact-embed" do
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
        .to include(contact["title"])
        .and include("[Contact: #{contact['content_id']}]")
    end

    it "renders a requirement issue with an unprocessable response when a contact is not selected" do
      post contact_embed_path(edition.document),
           params: { contact_id: nil }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body)
        .to include(I18n.t!("requirements.contact_embed.blank.form_message"))
    end
  end
end
