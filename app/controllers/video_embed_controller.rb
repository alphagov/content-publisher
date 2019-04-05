# frozen_string_literal: true

class VideoEmbedController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  def new
    if rendering_context != "modal"
      head :bad_request
      return
    end

    render :new, layout: rendering_context
  end

  def create
    if rendering_context != "modal"
      head :bad_request
      return
    end

    title = strip_tags(params[:title])
    url = strip_tags(params[:url])

    issues = Requirements::VideoEmbedChecker.new
      .pre_embed_issues(title: title, url: url)

    if issues.any?
      flash.now["alert_with_items"] = {
        "title" => t("video_embed.new.flashes.requirements"),
        "items" => issues.items,
      }

      render :new,
        assigns: { issues: issues },
        layout: rendering_context,
        status: :unprocessable_entity

      return
    end

    render inline: "[#{title}](#{url})"
  end
end
