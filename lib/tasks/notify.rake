# frozen_string_literal: true

namespace :notify do
  desc "Send an email notification"
  task :send_email, [:email_address] => :environment do |_, args|
    raise "Missing email address" unless args.email_address

    params = {
      to: args.email_address,
      template_id: ENV["TEMPLATE_ID"] || "759acac6-da53-4a19-b591-b7538c7c39de",
      body: ENV["BODY"] || "This is a test email notification",
      subject: ENV["SUBJECT"] || "Test email notification",
    }

    ActionMailer::Base.mail(**params).deliver_now
  end
end
