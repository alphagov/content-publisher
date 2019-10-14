# frozen_string_literal: true

# For more info, see https://docs.publishing.service.gov.uk/manual/content-preview.html#authentication
class PreviewAuthBypass
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def auth_bypass_id
    # Using the content_id directly would make it easier to brute force our jwt secret, so we hash it
    @auth_bypass_id ||= generate_uuid_for_string(document.content_id)
  end

  def preview_token
    JWT.encode(
      { "sub" => auth_bypass_id },
      Rails.application.secrets.jwt_auth_secret,
      "HS256",
    )
  end

private

  # See: http://ruby-doc.org/stdlib-1.9.3/libdoc/securerandom/rdoc/SecureRandom.html#uuid-method
  def generate_uuid_for_string(string)
    ary = Digest::SHA256.hexdigest(string).unpack("NnnnnN")
    ary[2] = (ary[2] & 0x0fff) | 0x4000
    ary[3] = (ary[3] & 0x3fff) | 0x8000
    "%08x-%04x-%04x-%04x-%04x%08x" % ary # rubocop:disable Style/FormatStringToken
  end
end
