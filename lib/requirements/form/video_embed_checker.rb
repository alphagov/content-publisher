class Requirements::Form::VideoEmbedChecker
  include Requirements::Checker

  YOUTUBE_HOST = "youtube.com".freeze
  YOUTU_HOST = "youtu.be".freeze

  attr_reader :title, :url

  def initialize(title: nil, url: nil)
    @title = title
    @url = url
  end

  def check
    if title.blank?
      issues.create(:video_embed_title, :blank)
    end

    if url.blank?
      issues.create(:video_embed_url, :blank)
    elsif !youtube_url?
      issues.create(:video_embed_url, :non_youtube)
    end
  end

private

  def youtube_url?
    uri = URI.parse(url)
    return true if uri.host.to_s.end_with?(YOUTU_HOST)

    uri.host.to_s.end_with?(YOUTUBE_HOST) &&
      uri.path == "/watch" && uri.query.to_s.match(/v=/)
  rescue URI::InvalidURIError
    false
  end
end
