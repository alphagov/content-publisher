# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ContentValidator do
  describe 'title validation' do
    it 'raises issue if the title is not set' do
      document = build(:document, title: nil)

      messages = ContentValidator.new(document).validation_messages

      expect(messages).to include("The title needs to be at least 10 characters long")
    end

    it 'raises issue if the title is too short' do
      document = build(:document, title: "Too short")

      messages = ContentValidator.new(document).validation_messages

      expect(messages).to include("The title needs to be at least 10 characters long")
    end

    it 'does not raise an issue if the title is fine' do
      document = build(:document, title: "Just long enough to validate.")

      messages = ContentValidator.new(document).validation_messages

      expect(messages).not_to include("The title needs to be at least 10 characters long")
    end
  end

  describe 'summary validation' do
    it 'raises issue if the summary is not set' do
      document = build(:document, summary: nil)

      messages = ContentValidator.new(document).validation_messages

      expect(messages).to include("The summary needs to be at least 10 characters long")
    end

    it 'raises issue if the summary is too short' do
      document = build(:document, summary: "Too short")

      messages = ContentValidator.new(document).validation_messages

      expect(messages).to include("The summary needs to be at least 10 characters long")
    end

    it 'does not raise an issue if the summary is fine' do
      document = build(:document, summary: "Just long enough to validate.")

      messages = ContentValidator.new(document).validation_messages

      expect(messages).not_to include("The summary needs to be at least 10 characters long")
    end
  end

  describe 'custom validation' do
    it 'raises issue if the summary is not set' do
      document = build(:document, :with_body_in_schema, contents: { body: "Too short" })

      messages = ContentValidator.new(document).validation_messages

      expect(messages).to include("Body needs to be at least 10 characters long")
    end
  end
end
