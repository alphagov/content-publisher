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
    it "can only be associated with either a retire or a remove child" do
      subject.id = SecureRandom.random_number(100)
      subject.retire = build(:retire, timeline_entry: subject)
      subject.remove = build(:remove, timeline_entry: subject)
      expect(subject).to_not be_valid
    end
  end
end
