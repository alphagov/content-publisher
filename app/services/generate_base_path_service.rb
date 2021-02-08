class GenerateBasePathService
  include PureFunctionObject

  def initialize(edition, title:, max_repeated_titles: 1000)
    @edition = edition
    @title = title.to_s
    @max_repeated_titles = max_repeated_titles
  end

  def call
    prefix = edition.document_type.path_prefix
    slug = title.parameterize
    base_path = create_path(prefix, slug)
    return base_path unless path_in_use?(base_path)

    find_a_unique_path(prefix, slug)
  end

private

  attr_reader :edition, :title, :max_repeated_titles

  def find_a_unique_path(prefix, slug)
    (1..max_repeated_titles).each do |appended_count|
      base_path = create_path(prefix, slug, appended_count)
      return base_path unless path_in_use?(base_path)
    end

    raise "Already >#{max_repeated_titles} paths with same title."
  end

  def path_in_use?(base_path)
    Document.using_base_path(base_path)
            .where.not("documents.id": edition.document_id)
            .exists?
  end

  def create_path(prefix, slug, count = nil)
    if count
      "#{prefix}/#{slug}-#{count}"
    else
      "#{prefix}/#{slug}"
    end
  end
end
