RSpec.describe Images::CreateInteractor do
  describe ".call" do
    let(:user) { create(:user) }
    let(:edition) { create(:edition) }
    let(:image_upload) { fixture_file_upload("960x640.jpg") }
    let(:args) do
      {
        params: {
          document: edition.document.to_param,
          image: image_upload,
        },
        user: user,
      }
    end

    context "when input is valid" do
      it "creates a new image revision" do
        expect { described_class.call(**args) }
          .to change { Image::Revision.count }.by(1)
      end

      it "normalises the uploaded image and delegates saving it to CreateImageBlobService" do
        temp_image = ImageNormaliser::TempImage.new(image_upload)
        normaliser = instance_double(ImageNormaliser, normalise: temp_image, issues: [])
        allow(ImageNormaliser).to receive(:new).and_return(normaliser)
        allow(CreateImageBlobService).to receive(:call).and_call_original

        described_class.call(**args)

        expect(ImageNormaliser).to have_received(:new).with(image_upload)
        expect(CreateImageBlobService)
          .to have_received(:call)
          .with(user: user, temp_image: temp_image, filename: an_instance_of(String))
      end

      it "attributes the various created image models to the user" do
        result = described_class.call(**args)
        image_revision = result.edition.image_revisions.first

        expect(image_revision.created_by).to eq(user)
        expect(image_revision.image.created_by).to eq(user)
        expect(image_revision.blob_revision.created_by).to eq(user)
        expect(image_revision.metadata_revision.created_by).to eq(user)
      end

      context "when a file already has the image filename" do
        let(:edition) do
          create(
            :edition,
            image_revisions: [create(:image_revision, filename: "960x640.jpg")],
          )
        end

        it "sets the image revision with a unique filename" do
          result = described_class.call(**args)
          expect(result.image_revision.filename).to eq("960x640-1.jpg")
        end
      end
    end

    context "when the edition isn't editable" do
      let(:edition) { create(:edition, :published) }

      it "raises a state error" do
        expect { described_class.call(**args) }
          .to raise_error(EditionAssertions::StateError)
      end
    end

    context "when the uploaded image has issues" do
      it "fails with issues returned" do
        allow(Requirements::Form::ImageUploadChecker)
          .to receive(:call).and_return(%w[issue])

        result = described_class.call(**args)

        expect(result).to be_failure
        expect(result.issues).to eq %w[issue]
      end
    end

    context "when the image normaliser finds issues" do
      it "fails with issues returned" do
        normaliser = instance_double(ImageNormaliser,
                                     normalise: nil,
                                     issues: %w[issue])

        allow(ImageNormaliser).to receive(:new).and_return(normaliser)
        result = described_class.call(**args)

        expect(result).to be_failure
        expect(result.issues).to match(%w[issue])
      end
    end
  end
end
