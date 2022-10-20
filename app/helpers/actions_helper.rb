module ActionsHelper
  def create_edition_button(edition, secondary: false)
    form_tag create_edition_path(edition.document),
             class: "app-side__form",
             data: { gtm: "create-new-edition" } do
      render "govuk_publishing_components/components/button",
             text: "Create new edition",
             secondary:
    end
  end

  def preview_button(edition, secondary: false)
    render "govuk_publishing_components/components/button",
           text: "Preview",
           data_attributes: { gtm: "preview" },
           href: preview_document_path(edition.document),
           secondary:
  end

  def delete_draft_link(edition, extra_classes = [])
    link_to "Delete draft",
            confirm_delete_draft_path(edition.document),
            class: %w[govuk-link app-link--destructive] + Array(extra_classes),
            data: { gtm: "delete-draft" }
  end

  def withdraw_link(edition)
    link_to "Withdraw",
            withdraw_path(edition.document),
            class: "govuk-link govuk-link--no-visited-state",
            data: { gtm: "withdraw" }
  end

  def remove_link(edition)
    link_to "Remove",
            remove_path(edition.document),
            class: "govuk-link app-link--destructive app-link--right",
            data: { gtm: "remove" }
  end

  def schedule_link(edition, extra_classes = [])
    link_to "Schedule",
            new_schedule_path(edition.document),
            class: %w[govuk-link govuk-link--no-visited-state] + Array(extra_classes),
            data: { gtm: "schedule" }
  end

  def schedule_button(edition)
    render "govuk_publishing_components/components/button",
           text: "Schedule to publish",
           data_attributes: { gtm: "schedule" },
           href: new_schedule_path(edition.document)
  end

  def schedule_proposal_link(edition, extra_classes = [])
    link_to "Schedule",
            schedule_proposal_path(edition.document, wizard: "schedule"),
            class: %w[govuk-link govuk-link--no-visited-state] + Array(extra_classes),
            data: { gtm: "propose-schedule" }
  end

  def publish_link(edition)
    link_to "Publish",
            publish_confirmation_path(edition.document),
            class: "govuk-link govuk-link--no-visited-state",
            data: { gtm: "publish" }
  end

  def undo_withdraw_button(edition)
    render "govuk_publishing_components/components/button",
           text: "Undo withdrawal",
           data_attributes: { gtm: "undo-withdraw" },
           href: unwithdraw_path(edition.document)
  end

  def publish_button(edition)
    render "govuk_publishing_components/components/button",
           text: "Publish",
           data_attributes: { gtm: "publish" },
           href: publish_confirmation_path(edition.document)
  end

  def create_preview_button(edition)
    form_tag preview_document_path(edition.document),
             class: "app-side__form",
             data: { gtm: "preview" } do
      render "govuk_publishing_components/components/button", text: "Preview"
    end
  end

  def approve_button(edition)
    form_tag approve_path(edition.document),
             class: "app-side__form",
             data: { gtm: "approve" } do
      render "govuk_publishing_components/components/button", text: "Approve"
    end
  end

  def submit_for_2i_button(edition)
    form_tag submit_for_2i_path(edition.document),
             class: "app-side__form",
             data: { gtm: "submit-for-2i" } do
      render "govuk_publishing_components/components/button", text: "Submit for 2i review"
    end
  end
end
