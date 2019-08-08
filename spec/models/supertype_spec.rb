# frozen_string_literal: true

RSpec.describe Supertype do
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
