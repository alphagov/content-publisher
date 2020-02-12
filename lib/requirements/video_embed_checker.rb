module Requirements
  class VideoEmbedChecker
    YOUTUBE_HOST = "youtube.com".freeze
    YOUTU_HOST = "youtu.be".freeze

    def pre_embed_issues(title: nil, url: nil)
      issues = CheckerIssues.new

      if title.blank?
        issues.create(:video_embed_title, :blank)
      end

      if url.blank?
        issues.create(:video_embed_url, :blank)
      elsif !youtube_url?(url)
        issues.create(:video_embed_url, :non_youtube)
      end

      issues
    end

  private

    def youtube_url?(url)
      uri = URI.parse(url)
      return true if uri.host.to_s.end_with?(YOUTU_HOST)

      uri.host.to_s.end_with?(YOUTUBE_HOST) &&
        uri.path == "/watch" && uri.query.to_s.match(/v=/)
    rescue URI::InvalidURIError
      false
    end
  end
end
