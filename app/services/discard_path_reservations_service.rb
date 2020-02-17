class DiscardPathReservationsService < ApplicationService
  def initialize(edition)
    @edition = edition
  end

  def call
    paths = edition.revisions.map(&:base_path).uniq.compact
    publishing_app = PreviewDraftEditionService::Payload::PUBLISHING_APP

    paths.each do |path|
      GdsApi.publishing_api.unreserve_path(path, publishing_app)
    rescue GdsApi::HTTPNotFound
      Rails.logger.warn("Tried to discard unreserved path #{path}")
    end
  end

private

  attr_reader :edition
end
