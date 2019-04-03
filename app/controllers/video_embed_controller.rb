# frozen_string_literal: true

class VideoEmbedController < ApplicationController
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

    render inline: "[#{params[:title]}](#{params[:url]})"
  end
end
