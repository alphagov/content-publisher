class Requirements::Form::FileAttachmentMetadataChecker < Requirements::Checker
  UNIQUE_REF_MAX_LENGTH = 255
  ISBN10_REGEX = /^(?:\d[\ -]?){9}[\dX]$/i.freeze
  ISBN13_REGEX = /^(?:\d[\ -]?){13}$/i.freeze
  ACT_PAPER_REGEX = /^\d+(-[IV]+)?$/.freeze
  COMMAND_PAPER_REGEX = /^(CP|C\.|Cd\.|Cmd\.|Cmnd\.|Cm\.)\s\d+(-[IV]+)?$/.freeze

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def check
    unless valid_isbn?(params[:isbn])
      issues.create(
        :file_attachment_isbn,
        :invalid,
      )
    end

    if params[:unique_reference].to_s.size > UNIQUE_REF_MAX_LENGTH
      issues.create(
        :file_attachment_unique_reference,
        :too_long,
        max_length: UNIQUE_REF_MAX_LENGTH,
      )
    end

    if params[:official_document_type].blank?
      issues.create(
        :file_attachment_official_document_type,
        :blank,
      )
    end

    %w[command act].each do |type|
      next unless (issue_key = invalid_paper_number?(type, params))

      issues.create(
        :"file_attachment_#{type}_paper_number",
        issue_key,
      )
    end
  end

private

  def valid_isbn?(isbn)
    isbn.blank? || ISBN10_REGEX.match?(isbn) || ISBN13_REGEX.match?(isbn)
  end

  def invalid_paper_number?(type, params)
    return unless params[:official_document_type] == "#{type}_paper"

    number = params[:"#{type}_paper_number"]
    return :blank if number.blank?

    regex = "#{self.class}::#{type.upcase}_PAPER_REGEX".constantize
    return :invalid unless regex.match?(number)
  end
end
