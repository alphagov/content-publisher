RSpec.describe Images::CreateInteractor do
  describe ".call" do
    let(:user) { create(:user) }
    let(:edition) { create(:edition) }
    let(:image_upload) { fixture_file_upload("files/960x640.jpg") }
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
      it "is successful" do
        expect(Images::CreateInteractor.call(**args)).to be_success
      end

      it "creates a new image revision" do
        expect { Images::CreateInteractor.call(**args) }
          .to change { Image::Revision.count }.by(1)
      end

      it "normalises the uploaded image and delegates saving it to CreateImageBlobService" do
        temp_image = ImageNormaliser::TempImage.new(image_upload)
        normaliser = instance_double(ImageNormaliser, normalise: temp_image, issues: [])
        expect(ImageNormaliser).to receive(:new).with(image_upload).and_return(normaliser)

        expect(CreateImageBlobService)
          .to receive(:call)
          .with(user: user, temp_image: temp_image, filename: an_instance_of(String))
          .and_call_original

        Images::CreateInteractor.call(**args)
      end

      it "attributes the various created image models to the user" do
        result = Images::CreateInteractor.call(**args)
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
          result = Images::CreateInteractor.call(**args)
          expect(result.image_revision.filename).to eq("960x640-1.jpg")
        end
      end
    end

    context "when the edition isn't editable" do
      let(:edition) { create(:edition, :published) }

      it "raises a state error" do
        expect { Images::CreateInteractor.call(**args) }
          .to raise_error(EditionAssertions::StateError)
      end
    end

    context "when the uploaded image has issues" do
      it "fails with issues returned" do
        issues = Requirements::CheckerIssues.new
        issues.create(:image, :examle)

        allow_any_instance_of(Requirements::ImageUploadChecker)
          .to receive(:issues).and_return(issues)

        result = Images::CreateInteractor.call(**args)

        expect(result).to be_failure
        expect(result.issues).to eq(issues)
      end
    end

    context "when the image normaliser finds issues" do
      it "fails with issues returned" do
        normaliser = instance_double(ImageNormaliser,
                                     normalise: nil,
                                     issues: %w(issue))

        allow(ImageNormaliser).to receive(:new).and_return(normaliser)
        result = Images::CreateInteractor.call(**args)

        expect(result).to be_failure
        expect(result.issues).to match(%w(issue))
      end
    end
  end
end
