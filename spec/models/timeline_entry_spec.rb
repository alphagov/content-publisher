# frozen_string_literal: true

RSpec.describe TimelineEntry do
  describe "#entry_type" do
    TimelineEntry::ENTRY_TYPES.each do |type|
      it "`#{type}` has a translation" do
        expect(I18n.exists?("documents.history.entry_types.#{type}")).to eql(true)
      end
    end
  end
end
