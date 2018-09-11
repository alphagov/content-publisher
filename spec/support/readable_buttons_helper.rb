module ReadableButtonsHelper
  def click_save
    # something like `click_on I18n.t("documents.edit.save_button")`
    click_on "Save"
  end

  def click_confirm_publish_button
    click_on "Confirm publish"
  end

  def click_continue
    click_on "Continue"
  end

  def click_new_document_button
    click_on "New document"
  end

  def click_try_again_button
    click_on "Try again"
  end

  def click_publish_button
    click_on "Publish"
  end
end
