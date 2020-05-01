class GenerateUniqueFilenameService < ApplicationService
  MAX_LENGTH = 65

  def initialize(filename:, existing_filenames:)
    @existing_filenames = existing_filenames
    @filename = ActiveStorage::Filename.new(filename)
  end

  def call
    base = filename.base.parameterize.slice 0...MAX_LENGTH
    base = ensure_unique(base)
    return base if filename.extension.blank?

    "#{base}.#{filename.extension}"
  end

private

  attr_reader :existing_filenames, :filename

  def ensure_unique(base)
    potential_conflicts = existing_filenames
                            .map(&ActiveStorage::Filename.method(:new))
                            .map(&:base)

    return base unless potential_conflicts.include?(base)

    "#{base}-#{unused_suffix(base, potential_conflicts)}"
  end

  def unused_suffix(suggested_base, potential_conflicts)
    suffix = 1

    suffix += 1 while potential_conflicts.include?("#{suggested_base}-#{suffix}")

    suffix
  end
end
