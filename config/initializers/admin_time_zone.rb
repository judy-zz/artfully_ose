module AdminTimeZone
  extend ActiveSupport::Concern
  def time_zone
    "Eastern Time (US & Canada)"
  end
end