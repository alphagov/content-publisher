# frozen_string_literal: true

require "singleton"

class I18nCov
  REPORT_PATH = Rails.root.join("coverage/i18n")
  IN_APP_LOCALE_FILES = Dir.glob(Rails.root.join("config/locales/**/*.yml"))

  include Singleton

  attr_reader :locales, :used_keys

  module I18nOverrides
    def lookup(locale, key, scope = [], options = {})
      I18nCov.log(key, scope)
      super
    end
  end

  class << self
    delegate :start, :report, :log, to: :instance
  end

  def start(locales = nil)
    @used_keys = []
    @locales = locales || in_app_locales
    I18n::Backend::Simple.include I18nOverrides
  end

  def log(key, scope)
    key = (Array(scope || []) + [key]).compact.join(".")
    used_keys << key unless used_keys.include?(key)
  end

  def report
    return if used_keys.blank?

    all = all_locale_keys
    scoped_used = all.select { |as| used_keys.any? { |us| as.start_with?(us) } }

    write_report(all - scoped_used)
    print_message(all, scoped_used)
  end

private

  def in_app_locales
    IN_APP_LOCALE_FILES.map(&YAML.method(:load_file)).reduce({}, :deep_merge)
  end

  def all_locale_keys
    locales.flat_map { |locale, ts| key_chains_for(locale, ts, is_root: true) }
      .map { |key_chain| key_chain.join(".") }.uniq
  end

  def key_chains_for(key, value, is_root: false)
    return [[key]] unless value.is_a? Hash

    value.flat_map { |sub_key, sub_value| key_chains_for(sub_key, sub_value) }
      .map { |sub_key| (is_root ? [] : [key]) + sub_key }
  end

  def write_report(unused)
    FileUtils.mkdir_p(File.dirname(REPORT_PATH))

    File.open(REPORT_PATH, "w") do |f|
      f.puts("Keys not covered (potentially unused)\n\n")
      unused.each { |key| f.puts key }
    end
  end

  def print_message(all, used)
    percent = ((used.count.to_f / all.count) * 100).round(2)

    puts "Coverage report generated for I18n to #{Dir.pwd}/coverage/i18n. " +
      "#{used.count} / #{all.count} keys (#{percent}%) covered."
  end
end

END { I18nCov.report }
