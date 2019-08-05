# frozen_string_literal: true

class VideoEmbed::CreateInteractor < ApplicationInteractor
  include ActionView::Helpers::TextHelper

  delegate :params,
           :title,
           :url,
           to: :context

  def call
    sanitize_title_and_url
    check_for_issues
    generate_markdown_code
  end

private

  def sanitize_title_and_url
    context.title = strip_tags(params[:title])
    context.url = strip_tags(params[:url])
  end

  def check_for_issues
    issues = Requirements::VideoEmbedChecker.new
      .pre_embed_issues(title: title, url: url)

    context.fail!(issues: issues) if issues.any?
  end

  def generate_markdown_code
    context.markdown_code = "[#{title}](#{url})"
  end
end
