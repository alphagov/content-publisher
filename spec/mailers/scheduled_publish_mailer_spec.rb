# frozen_string_literal: true

RSpec.describe ScheduledPublishMailer do
  before do
    @user = create(:user)

    published_at = Time.current
    @publish_time = published_at.strftime("%-l:%M%P")
    @publish_date = published_at.strftime("%d %B %Y")
  end

  describe "sending an email when scheduled edition is published" do
    it "renders non-specific mail content" do
      edition = create(:edition, :published, title: "yolo")
      mail = ScheduledPublishMailer.success_email(edition, @user).deliver_now
      body = mail.body.encoded

      expect(mail.to).to eq([@user.email])
      expect(body).to include("https://www.test.gov.uk/prefix/yolo")
      expect(body).to include(document_path(edition.document))
      expect(body).to include(
        I18n.t("scheduled_publish_mailer.success_email.scheduled_by",
               name: @user.name),
      )
    end

    it "renders mail content for publishing the first edition with 2i" do
      edition = create(:edition, :published, title: "yolo")
      mail = ScheduledPublishMailer.success_email(edition, @user).deliver_now
      body = mail.body.encoded

      expect(mail.subject).to eq(
        I18n.t("scheduled_publish_mailer.success_email.subject.published",
               title: edition.title),
      )
      expect(body).to include(
        I18n.t("scheduled_publish_mailer.success_email.details.publish",
               time: @publish_time,
               date: @publish_date),
      )
    end

    it "renders mail content for publishing the first edition without 2i" do
      edition = create(:edition, state: "published_but_needs_2i", title: "yolo")
      mail = ScheduledPublishMailer.success_email(edition, @user).deliver_now
      body = mail.body.encoded

      expect(mail.subject).to eq(
        I18n.t("scheduled_publish_mailer.success_email.subject.published_but_needs_2i",
               title: edition.title),
      )
      expect(body).to include(
        I18n.t("scheduled_publish_mailer.success_email.details.publish",
               time: @publish_time,
               date: @publish_date),
      )
    end

    it "renders mail content for updating a published edition" do
      edition = create(:edition, :published, number: 2, title: "yolo")
      mail = ScheduledPublishMailer.success_email(edition, @user).deliver_now
      body = mail.body.encoded

      expect(mail.subject).to eq(
        I18n.t("scheduled_publish_mailer.success_email.subject.update",
               title: edition.title),
      )
      expect(body).to include(
        I18n.t("scheduled_publish_mailer.success_email.details.update",
               time: @publish_time,
               date: @publish_date),
      )
    end
  end
end
