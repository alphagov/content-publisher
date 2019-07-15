# frozen_string_literal: true

RSpec.describe EditionAssertions do
  include EditionAssertions

  describe "#assert_edition_state" do
    let(:edition) { build :edition }

    it "does nothing when the assertion block returns true" do
      expect { assert_edition_state(edition) { true } }.to_not raise_error
    end

    it "throws an error when the assertion block is false" do
      expect { assert_edition_state(edition) { false } }
        .to raise_error(EditionAssertions::StateError)
    end

    it "can throw errors with custom messaging" do
      expect { assert_edition_state(edition, assertion: "custom messaging") { false } }
        .to raise_error(EditionAssertions::StateError, /custom messaging/)
    end
  end
end
