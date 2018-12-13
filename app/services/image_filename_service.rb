# frozen_string_literal: true

class ImageFilenameService
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def call(suggested_name, mime_type)
    normalised_name = normalise(suggested_name, mime_type)
    ensure_unique(normalised_name)
  end

private

  def images
    @images ||= document.images
  end

  def normalise(name, type)
    filename = ActiveStorage::Filename.new(name)
    extension = Rack::Mime::MIME_TYPES.invert[type]
    "#{filename.base.parameterize}#{extension}"
  end

  def ensure_unique(name)
    bases = document.images.pluck(:filename)
      .map(&ActiveStorage::Filename.method(:new))
      .map(&:base)

    filename = ActiveStorage::Filename.new(name)
    return name unless bases.include?(filename.base)

    suffix = unused_suffix(filename.base, bases)
    "#{filename.base}-#{suffix}.#{filename.extension}"
  end

  def unused_suffix(suggested_base, bases)
    suffixes = bases.map do |base|
      match = base.match(/^#{suggested_base}-([0-9]+)$/)
      match.to_a[1].to_i
    end

    ((1..(bases.count + 1)).to_a - suffixes).min
  end
end
