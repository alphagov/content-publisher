class Requirements::Form::WithdrawalChecker
  include Requirements::Checker

  attr_reader :edition, :public_explanation

  def initialize(edition, public_explanation, **)
    @edition = edition
    @public_explanation = public_explanation
  end

  def check
    if public_explanation.blank?
      issues.create(:public_explanation, :blank)
    end

    unless GovspeakDocument.new(public_explanation, edition).valid?
      issues.create(:public_explanation, :invalid_govspeak)
    end
  end
end
