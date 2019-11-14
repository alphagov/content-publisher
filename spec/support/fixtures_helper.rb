# frozen_string_literal: true

module FixturesHelper
  def fixtures_path
    File.expand_path(Rails.root + "spec/fixtures")
  end

  def whitehall_export_with_one_edition
    JSON.parse(File.read(fixtures_path + "/whitehall_export_with_one_edition.json"))
  end

  def whitehall_export_with_two_editions
    JSON.parse(File.read(fixtures_path + "/whitehall_export_with_two_editions.json"))
  end

  def whitehall_export_with_one_withdrawn_edition
    JSON.parse(File.read(fixtures_path + "/whitehall_export_with_one_withdrawn_edition.json"))
  end
end
