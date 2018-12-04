# frozen_string_literal: true

RSpec.describe TimelineEntry do
  describe "#entry_type" do
    TimelineEntry::ENTRY_TYPES.each do |type|
      it "`#{type}` has a translation" do
        expect(I18n.exists?("documents.history.entry_types.#{type}")).to eql(true)
      end
    end
  end

  describe "#can_only_have_one_associated_type" do
    it "can only be associated with either a retirement or a removal child" do
      subject.id = SecureRandom.random_number(100)
      subject.retirement = build(:retirement, timeline_entry: subject)
      subject.removal = build(:removal, timeline_entry: subject)
      expect(subject).to_not be_valid
    end
  end
end
