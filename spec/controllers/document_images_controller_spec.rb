# frozen_string_literal: true

RSpec.describe DocumentImagesController do
  describe "POST create" do
    context "when a request doesn't have errors" do
      let(:upload) { fixture_file_upload("files/960x640.jpg", "image/jpeg") }

      it "has a 201 status code" do
        post :create, params: { image: upload, document_id: create(:document).id }
        expect(response.status).to eql(201)
      end

      it "returns a JSON representation" do
        post :create, params: { image: upload, document_id: create(:document).id }
        json = JSON.parse(response.body)
        expect(json).to match(
          a_hash_including(
            "id" => a_kind_of(Integer),
            "filename" => "960x640.jpg",
            "original" => hash_including(
              "dimensions" => hash_including("width" => 960, "height" => 640),
              "path" => match(%r{\A/rails/active_storage/blobs/}),
            ),
            "crop" => hash_including(
              "dimensions" => hash_including("width" => 960, "height" => 640),
              "offset" => hash_including("x" => 0, "y" => 0),
              "path" => match(%r{\A/rails/active_storage/representations/}),
            ),
          ),
        )
      end

      it "creates an image" do
        create = -> do
          post :create, params: { image: upload, document_id: create(:document).id }
        end
        expect(create).to change { Image.count }.by(1)
      end
    end

    context "when a wrong file type is uploaded" do
      let(:upload) { fixture_file_upload("files/text-file.txt", "text/plain") }

      it "has a 422 status code" do
        post :create, params: { image: upload, document_id: create(:document).id }
        expect(response.status).to eql(422)
      end

      it "returns errors" do
        post :create, params: { image: upload, document_id: create(:document).id }
        json = JSON.parse(response.body)
        expect(json).to match(a_hash_including("errors"))
        expect(json["errors"].count).to be > 0
      end
    end
  end

  describe "POST crop" do
    context "when the crop is valid" do
      it "returns the updated crop" do
        image = create(:image, fixture: "1000x1000.jpg", width: 1000, height: 1000)

        post :create, params: {
          document_id: image.document.id,
          id: image.id,
          crop: { x: 10, y: 10, width: 960, Height: 640 },
        }

        expect(response.status).to eql(200)
        expect(JSON.parse(response.body)).to match(
          a_hash_including(
            "crop" => hash_including(
              "dimensions" => hash_including("width" => 960, "height" => 640),
              "offset" => hash_including("x" => 0, "y" => 0),
            ),
          )
        )
      end
    end

    context "when the crop is invalid" do
      it "returns the errors" do
        image = create(:image, fixture: "1000x1000.jpg", width: 1000, height: 1000)

        post :create, params: {
          document_id: image.document.id,
          id: image.id,
          crop: { x: 10, y: 10, width: 960, Height: 100 },
        }

        expect(response.status).to eql(422)
        json = JSON.parse(response.body)
        expect(json).to match(a_hash_including("errors"))
        expect(json["errors"].count).to be > 0
      end
    end
  end
end
