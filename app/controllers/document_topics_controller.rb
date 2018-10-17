# frozen_string_literal: true

class DocumentTopicsController < ApplicationController
  def edit
    @document = Document.find_by_param(params[:document_id])
    @tree = TopicsService.new.tree
  end
end
