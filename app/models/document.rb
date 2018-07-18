# frozen_string_literal: true

class Document < ApplicationRecord
  has_paper_trail

  def previewable_in_current_state?
    [title, description].all?(&:present?)
  end
end
