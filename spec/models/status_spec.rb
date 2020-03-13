RSpec.describe Status do
  describe ".states" do
    described_class.states.each_key do |state|
      it "has a translation for `#{state}`" do
        expect(I18n.exists?("user_facing_states.#{state}.name")).to be true
      end
    end
  end
end
