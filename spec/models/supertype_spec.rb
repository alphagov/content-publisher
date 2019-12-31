# frozen_string_literal: true

RSpec.describe Supertype do
  describe "all configured supertypes are valid" do
    Supertype.all.each do |supertype|
      describe "Supertype #{supertype.id}" do
        it "has the required attributes for #{supertype.id}" do
          expect(supertype.id).to_not be_blank
          expect(supertype.label).to_not be_blank
          expect(supertype.description).to_not be_blank
        end
      end
    end
  end

  describe ".find" do
    it "returns a Supertype when it's a known supertype" do
      expect(Supertype.find("news")).to be_a(Supertype)
    end

    it "raises a RuntimeError when we don't know the supertype" do
      expect { Supertype.find("unknown_supertype") }
        .to raise_error(RuntimeError, "Supertype unknown_supertype not found")
    end
  end
end
