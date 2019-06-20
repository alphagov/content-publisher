# frozen_string_literal: true

RSpec.describe PublishMailer do
  let(:recipient) { build(:user) }

  describe "#publish_email" do
    it "creates an email for the user" do
      edition = build(:edition, :published, base_path: "/news/some-great-news")

      mail = PublishMailer.publish_email(recipient, edition, edition.status)
      mail_subject = I18n.t!("publish_mailer.publish_email.subject.published",
                             title: edition.title)

      expect(mail.to).to eq([recipient.email])
      expect(mail.subject).to eq(mail_subject)
      expect(mail.body.to_s).to include("https://www.test.gov.uk/news/some-great-news")
      expect(mail.body.to_s).to include(document_path(edition.document))
    end

    it "includes when the edition was published" do
      edition = build(:edition,
                      :published,
                      published_at: Time.zone.parse("2019-06-17 9:00"))

      mail = PublishMailer.publish_email(recipient, edition, edition.status)
      publish_time = I18n.t!("publish_mailer.publish_email.details.publish",
                             date: "17 June 2019",
                             time: "9:00am",
                             user: recipient.name)

      expect(mail.body.to_s).to include(publish_time)
    end

    context "when the edition published needs 2i review" do
      it "informs recipients" do
        edition = build(:edition, :published, state: :published_but_needs_2i)

        mail = PublishMailer.publish_email(recipient, edition, edition.status)

        review_notice = I18n.t!("publish_mailer.publish_email.2i_warning")
        expect(mail.body.to_s).to include(review_notice)
      end
    end

    context "when a subsequent edition is published" do
      it "includes when the edition was updated" do
        edition = build(:edition,
                        :published,
                        number: 2,
                        published_at: Time.zone.parse("2019-06-17 23:00"))

        mail = PublishMailer.publish_email(recipient, edition, edition.status)
        update_text = I18n.t!("publish_mailer.publish_email.details.update",
                              date: "17 June 2019",
                              time: "11:00pm",
                              user: recipient.name)
        mail_subject = I18n.t!("publish_mailer.publish_email.subject.update",
                               title: edition.title)

        expect(mail.subject).to eq(mail_subject)
        expect(mail.body.to_s).to include(update_text)
      end

      it "includes the change note for a major change" do
        edition = build(:edition,
                        :published,
                        number: 2,
                        update_type: "major",
                        change_note: "Massive sweeping change")

        mail = PublishMailer.publish_email(recipient, edition, edition.status)

        expect(mail.body.to_s).to include("Massive sweeping change")
      end

      it "has a generic change note for a minor change" do
        edition = build(:edition,
                        :published,
                        number: 2,
                        update_type: "minor",
                        change_note: "Tiny change")

        mail = PublishMailer.publish_email(recipient, edition, edition.status)

        expect(mail.body.to_s).not_to include("Tiny change")
        expect(mail.body.to_s)
          .to include(I18n.t!("publish_mailer.publish_email.minor_update"))
      end
    end
  end
end
