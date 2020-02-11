RSpec.describe EditionAssertions do
  include described_class

  describe "#assert_edition_state" do
    let(:edition) { build :edition }

    it "does nothing when the assertion block returns true" do
      expect { assert_edition_state(edition) { true } }.not_to raise_error
    end

    it "raises an error when the assertion block is false" do
      expect { assert_edition_state(edition) { false } }
        .to raise_error(EditionAssertions::StateError)
    end

    it "can raise errors with custom messaging" do
      expect { assert_edition_state(edition, assertion: "custom messaging") { false } }
        .to raise_error(EditionAssertions::StateError, /custom messaging/)
    end
  end
end
