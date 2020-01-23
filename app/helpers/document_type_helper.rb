# frozen_string_literal: true

module DocumentTypeHelper
  def t_doctype_field?(edition, partial_i18n_key)
    i18n_key = prefix_doctype_field(edition, partial_i18n_key)
    I18n.exists?(i18n_key) || I18n.exists?(doctype_default_key(i18n_key))
  end

  def t_doctype_field(edition, partial_i18n_key)
    i18n_key = prefix_doctype_field(edition, partial_i18n_key)
    I18n.t!(I18n.exists?(i18n_key) ? i18n_key : doctype_default_key(i18n_key))
  end

private

  def prefix_doctype_field(edition, partial_i18n_key)
    "document_types.#{edition.document_type.id}.fields.#{partial_i18n_key}"
  end

  def doctype_default_key(i18n_key)
    parts = i18n_key.split(".")
    parts[1] = "default"
    parts.join(".")
  end
end
