require_relative Rails.root.join("spec/support/i18n_cov.rb")

namespace :i18n_cov do
  desc "Prints I18n Coverage report and returns exit status"
  task ci: :environment do
    report = JSON.parse(File.read(I18nCov::REPORT_PATH))
    percent_coverage = report["stats"]["coverage"]
    Kernel.exit 0 if percent_coverage == 100

    puts JSON.pretty_generate(report)
    puts "I18n coverage (#{percent_coverage}%) is below the expected minimum coverage (100%)"
    puts "I18nCov failed with exit 1\n"

    Kernel.exit 1
  end
end
