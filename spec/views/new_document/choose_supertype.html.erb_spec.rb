RSpec.describe "new_document/choose_supertype.html.erb" do
  describe "input values for Supertypes" do
    it "has an input radio for every Supertype" do
      render

      Supertype.all.each do |supertype|
        expect(rendered).to have_selector("input[value=#{supertype.id}]")
      end
    end
  end
end
