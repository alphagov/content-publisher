class GoogleAuthController < ApplicationController
  def callback
    redirect_to documents_path
  end
end
