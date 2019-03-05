# frozen_string_literal: true

RSpec.describe Versioning::ImageRevisionUpdater do
  describe "#assign" do
    let(:user) { create :user }

    let(:revision) do
      create(
        :image_revision,
        alt_text: "old alt text",
        crop_x: 1,
      )
    end

    it "raises an error for unexpected attributes" do
      updater = Versioning::ImageRevisionUpdater.new(revision, user)
      expect { updater.assign(foo: "bar") }.to raise_error ActiveModel::UnknownAttributeError
    end

    it "creates a new revision when a value changes" do
      updater = Versioning::ImageRevisionUpdater.new(revision, user)
      updater.assign(alt_text: "new alt text")

      next_revision = updater.next_revision
      expect(next_revision).to_not eq revision
      expect(next_revision.created_by).to eq user
    end

    it "updates and reports changes to the fields" do
      updater = Versioning::ImageRevisionUpdater.new(revision, user)

      new_fields = {
        alt_text: "new alt text",
        crop_x: 2,
      }

      updater.assign(new_fields)
      next_revision = updater.next_revision

      expect(updater.changed?).to be_truthy
      expect(updater.changes).to include(new_fields)

      new_fields.each do |name, value|
        expect(updater.changed?(name)).to be_truthy
        expect(next_revision.public_send(name)).to eq value
      end
    end

    it "preserves the current revision if no change" do
      updater = Versioning::ImageRevisionUpdater.new(revision, user)

      old_fields = {
        alt_text: revision.alt_text,
        crop_x: revision.crop_x,
      }

      updater.assign(old_fields)
      expect(updater.changed?).to be_falsey
      expect(updater.changes).to be_empty
      expect(updater.next_revision).to eq revision
    end

    it "preserves existing values when others change" do
      updater = Versioning::ImageRevisionUpdater.new(revision, user)

      old_fields = {
        alt_text: revision.alt_text,
        crop_x: revision.crop_x,
      }

      updater.assign(credit: "new credit")
      next_revision = updater.next_revision

      expect(next_revision).to_not eq revision

      old_fields.each do |name, value|
        expect(next_revision.public_send(name)).to eq value
      end
    end
  end
end
