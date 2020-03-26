require "singleton"

class I18nCov
  REPORT_PATH = Rails.root.join("coverage/i18n.json")
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

    unused_keys = check_unused_keys
    report = generate_report(unused_keys)
    write_report(report)
    print_message(report)
  end

private

  def in_app_locales
    IN_APP_LOCALE_FILES.map(&YAML.method(:load_file)).reduce({}, :deep_merge)
  end

  def all_locale_keys
    @all_locale_keys ||= locales
      .flat_map { |locale, ts| key_chains_for(locale, ts, is_root: true) }
      .map { |key_chain| key_chain.join(".") }.uniq
  end

  def key_chains_for(key, value, is_root: false)
    return [[key]] unless value.is_a? Hash

    value.flat_map { |sub_key, sub_value| key_chains_for(sub_key, sub_value) }
      .map { |sub_key| (is_root ? [] : [key]) + sub_key }
  end

  def check_unused_keys
    all_locale_keys.reject { |as| used_keys.any? { |us| as.start_with?(us) } }
  end

  def generate_report(unused_keys)
    used_count = all_locale_keys.count - unused_keys.count

    {
      stats: {
        used_keys: used_count,
        all_keys: all_locale_keys.count,
        coverage: ((used_count.to_f / all_locale_keys.count) * 100).round(2),
      },
      unused_keys: {
        description: "Keys not covered (potentially unused)",
        items: unused_keys,
      },
    }
  end

  def write_report(report)
    FileUtils.mkdir_p(File.dirname(REPORT_PATH))
    File.write(REPORT_PATH, JSON.pretty_generate(report))
  end

  def print_message(report)
    puts "Coverage report generated for I18n to #{REPORT_PATH}. " +
      "#{report[:stats][:used_keys]} / #{report[:stats][:all_keys]} keys " +
      "(#{report[:stats][:coverage]}%) covered."
  end
end

END { I18nCov.report }
