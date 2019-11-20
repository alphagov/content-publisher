# frozen_string_literal: true

class Government
  include ActiveModel::Model

  def self.find(id)
    all.find { |government| government.id == id }
  end

  def self.for_date(date)
    all.find { |government| government.covers?(date) }
  end

  def self.current
    for_date(Date.current)
  end

  def self.all
    @all ||= YAML.load_file(Rails.root.join("config", "governments.yml"))
                 .map { |hash| new(hash) }
  end

  attr_accessor :id, :slug, :name, :start_date, :end_date

  def ==(other)
    id == other.id
  end

  def eql?(other)
    self == other
  end

  def covers?(date)
    return false if date < start_date
    # Most end dates in Whitehall are the last date of a government so we
    # treat the date as going up to 23:59:59 on the day by appending 1 day to
    # the date
    return false if end_date && date >= (end_date + 1)

    true
  end
end
