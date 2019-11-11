# frozen_string_literal: true

class SuggestTopicsService < ApplicationService
  def initialize(edition)
    @edition = edition
  end

  def call
    # uri = URI(Rails.application.secrets.tagging_suggester_api_url)
    uri = URI("https://tagging-suggester.herokuapp.com:80/create")
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = { text: combined_text(@edition), edition_id: @edition.id }.to_json
    begin
      res = Net::HTTP.start(uri.hostname, uri.port, read_timeout: 4000) do |http|
        http.request(req)
      end
    rescue StandardError => e
      # We don't want to prevent people tagging manually
      # so swallow any errors
      GovukError.notify(e)
      return []
    end
    parse_suggestions(JSON.parse(res.body)["suggestions"])
  end

private

  def parse_suggestions(suggestions)
    suggestions.each_with_index.map do |suggestion, index|
      SuggestedTopic.new(suggestion, index)
    end
  end

  def combined_text(edition)
    "#{edition.title} #{edition.summary} #{edition.contents.values.join(" ")}"
  end
end


