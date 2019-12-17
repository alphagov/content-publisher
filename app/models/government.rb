# frozen_string_literal: true

class Government
  include InitializeWithHash

  attr_accessor :content_id, :locale, :title, :details

  def ==(other)
    content_id == other.content_id && locale == other.locale
  end

  alias_method :eql?, :==

  def covers?(date)
    return false if date < started_on
    # Most end dates in Whitehall are the last date of a government so we
    # treat the date as going up to 23:59:59 on the day by appending 1 day to
    # the date
    return false if ended_on && date >= (ended_on + 1)

    true
  end

  def started_on
    @started_on ||= Date.parse(details["started_on"])
  end

  def ended_on
    @ended_on ||= Date.parse(details["ended_on"]) if details["ended_on"]
  end

  def current?
    details["current"] == true
  end
end
