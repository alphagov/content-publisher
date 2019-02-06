# frozen_string_literal: true

class UnwithdrawController < ApplicationController
  def confirm
    @document = Document.with_current_edition.find_by_param(params[:id])

    if !current_user.has_permission?(User::PRE_RELEASE_FEATURES_PERMISSION)
      render :non_pre_release
      return
    end

    if current_user.has_permission?(User::MANAGING_EDITOR_PERMISSION)
      redirect_to document_path(@document), confirmation: "unwithdraw/confirm"
    else
      render :non_managing_editor
    end
  end

  def unwithdraw
    redirect_to document_path(params[:id])
  end
end
