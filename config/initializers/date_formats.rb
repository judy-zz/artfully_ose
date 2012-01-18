Time::DATE_FORMATS.merge! \
  :datetimepicker => lambda { |time| time.strftime("%Y-%m-%d %I:%M %p").downcase }
