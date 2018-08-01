# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SupertypeSchema do
  describe ".find" do
    it "returns a SupertypeSchema when it's a known supertype" do
      expect(SupertypeSchema.find("news")).to be_a(SupertypeSchema)
    end

    it "raises a RuntimeError when we don't know the supertype" do
      expect { SupertypeSchema.find("unknown_supertype") }
        .to raise_error(RuntimeError, "Supertype unknown_supertype not found")
    end
  end
end
