# frozen_string_literal: true

RSpec.describe Status do
  describe ".states" do
    Status.states.keys.each do |state|
      it "has a translation for `#{state}`" do
        expect(I18n.exists?("user_facing_states.#{state}.name")).to be true
      end
    end
  end
end
