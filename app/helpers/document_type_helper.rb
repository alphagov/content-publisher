# frozen_string_literal: true

module DocumentTypeHelper
  def t_doctype_exists?(i18n_key)
    I18n.exists?(i18n_key) || I18n.exists?(doctype_default_key(i18n_key))
  end

  def t_doctype(i18n_key)
    match = I18n.t!(I18n.exists?(i18n_key) ? i18n_key : doctype_default_key(i18n_key))
    match.is_a?(String) ? match : match.stringify_keys
  end

private

  def doctype_default_key(i18n_key)
    parts = i18n_key.split(".")
    parts[1] = "default"
    parts.join(".")
  end
end
