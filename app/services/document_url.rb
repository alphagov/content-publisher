# frozen_string_literal: true

class DocumentUrl
  def initialize(document)
    @document = document
  end

  def public_url
    return unless document.base_path
    Plek.new.website_root + document.base_path
  end

  def preview_url
    return unless document.base_path
    Plek.new.external_url_for("draft-origin") + document.base_path
  end

  def secret_preview_url
    return unless document.base_path
    params = { token: secret_token_for_preview_url }.to_query
    preview_url + "?" + params
  end

  # Return a "auth_bypass_id" to send to the publishing-api. This token will
  # be used to give one-time access to a piece of draft content.
  #
  # The token is first sent to the publishing-api in the payload. It is persisted
  # in the content store. Users will then be allowed to visit the draft stack
  # with a token in the URL. This JWT token is generated using the same `auth_bypass_id`,
  # which means the the draft stack can determine if the token allows access to
  # a specific piece of content.
  #
  # For more info, see https://docs.publishing.service.gov.uk/manual/content-preview.html#authentication
  def auth_bypass_id
    @_auth_bypass_id ||= generate_uuid_for_string(document.content_id)
  end

private

  attr_reader :document

  def secret_token_for_preview_url
    JWT.encode(
      { "sub" => auth_bypass_id },
      Rails.application.secrets.jwt_auth_secret,
      "HS256",
    )
  end

  # Generate a deterministic UUID from a string.
  #
  # The code to create the token has been borrowed from SecureRandom.uuid.
  #
  # See: http://ruby-doc.org/stdlib-1.9.3/libdoc/securerandom/rdoc/SecureRandom.html#uuid-method
  def generate_uuid_for_string(string)
    ary = Digest::SHA256.hexdigest(string).unpack("NnnnnN")
    ary[2] = (ary[2] & 0x0fff) | 0x4000
    ary[3] = (ary[3] & 0x3fff) | 0x8000
    "%08x-%04x-%04x-%04x-%04x%08x" % ary
  end
end
