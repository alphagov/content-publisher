# frozen_string_literal: true

RSpec.describe ScheduledPublishMailer do
  let(:recipient) { build(:user) }

  describe ".success_email" do
    it "creates an email for the user" do
      edition = build(:edition, :published)
      mail = ScheduledPublishMailer.success_email(recipient, edition, edition.status)

      expect(mail.to).to eq([recipient.email])

      mail_subject = I18n.t!("scheduled_publish_mailer.success_email.subject.published",
                             title: edition.title)
      expect(mail.subject).to eq(mail_subject)
    end

    it "includes when the edition was published" do
      edition = build(:edition,
                      :published,
                      published_at: Time.zone.parse("2019-06-17 9:00"))

      mail = ScheduledPublishMailer.success_email(recipient, edition, edition.status)

      publish_time = I18n.t!("scheduled_publish_mailer.success_email.details.publish",
                             date: "17 June 2019",
                             time: "9:00am")
      expect(mail.body.to_s).to include(publish_time)
    end

    it "includes who scheduled the edition" do
      publisher = build(:user, name: "Government Publisher")
      edition = build(:edition, :published, created_by: publisher)

      mail = ScheduledPublishMailer.success_email(recipient, edition, edition.status)

      scheduled_by = I18n.t!("scheduled_publish_mailer.success_email.scheduled_by",
                             name: "Government Publisher")
      expect(mail.body.to_s).to include(scheduled_by)
    end

    context "when the edition published needs 2i review" do
      it "informs recipients" do
        edition = build(:edition, :published, state: :published_but_needs_2i)

        mail = ScheduledPublishMailer.success_email(recipient, edition, edition.status)

        review_notice = I18n.t!("scheduled_publish_mailer.success_email.2i_warning")
        expect(mail.body.to_s).to include(review_notice)
      end
    end

    context "when a subsequent edition is published" do
      it "includes when the edition was updated" do
        edition = build(:edition,
                        :published,
                        number: 2,
                        published_at: Time.zone.parse("2019-06-17 23:00"))

        mail = ScheduledPublishMailer.success_email(recipient, edition, edition.status)

        update_text = I18n.t!("scheduled_publish_mailer.success_email.details.update",
                              date: "17 June 2019",
                              time: "11:00pm")
        expect(mail.body.to_s).to include(update_text)
      end

      it "includes the change note for a major change" do
        edition = build(:edition,
                        :published,
                        number: 2,
                        update_type: "major",
                        change_note: "Massive sweeping change")

        mail = ScheduledPublishMailer.success_email(recipient, edition, edition.status)

        expect(mail.body.to_s).to include("Massive sweeping change")
      end

      it "has a generic change note for a minor change" do
        edition = build(:edition,
                        :published,
                        number: 2,
                        update_type: "minor",
                        change_note: "Tiny change")

        mail = ScheduledPublishMailer.success_email(recipient, edition, edition.status)

        expect(mail.body.to_s).not_to include("Tiny change")
        expect(mail.body.to_s)
          .to include(I18n.t!("scheduled_publish_mailer.success_email.minor_update"))
      end
    end
  end

  describe ".failure_email" do
    it "creates an email for the user" do
      edition = build(:edition, :failed_to_publish)
      mail = ScheduledPublishMailer.failure_email(recipient, edition, edition.status)

      expect(mail.to).to eq([recipient.email])

      mail_subject = I18n.t!("scheduled_publish_mailer.failure_email.subject",
                             title: edition.title)
      expect(mail.subject).to eq(mail_subject)
    end

    it "includes the time that publishing was expected" do
      scheduling = build(:scheduling,
                         publish_time: Time.zone.parse("2019-06-17 12:00"))
      edition = build(:edition, :failed_to_publish, scheduling: scheduling)

      mail = ScheduledPublishMailer.failure_email(recipient, edition, edition.status)

      publish_time = I18n.t!("scheduled_publish_mailer.failure_email.schedule_date",
                             date: "17 June 2019",
                             time: "12:00pm")
      expect(mail.body.to_s).to include(publish_time)
    end
  end
end
