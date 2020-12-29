class StubApis::PublishingApiController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def get_linkables
    puts "get_linkables"
    render json: []
  end

  def get_content
    puts "get_content"
    render json: {}
  end

  def put_content
    puts "put_content"
    data = JSON.parse request.body.read
    render json: data
  end

  def publish_content
    puts "publish_content"
    data = JSON.parse request.body.read
    render json: data
  end

  def get_editions
    puts "get_editions"
    render json: {
      results: [],
      links: []
    }
  end
end
