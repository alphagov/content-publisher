# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Document do
  describe "PUBLICATION_STATES" do
    it "has correct translations for each state" do
      Document::PUBLICATION_STATES.each do |state|
        I18n.t!("documents.show.publication_state.#{state}.name")
        I18n.t!("documents.show.publication_state.#{state}.description")
      end
    end
  end
end
