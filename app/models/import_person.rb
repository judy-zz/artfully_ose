class ImportPerson

  def initialize(headers, row)
    @headers = headers
    @row = row

    %w(
      email first last company
      address1 address2 city state zip country
      phone1_type phone1_number phone2_type phone2_number phone3_type phone3_number
      website twitter_username facebook_page linkedin_page
      tags
    ).each { |field| load_value field }
  end

  def load_value(field)
    index = @headers.index { |h| h.to_s.downcase.strip == field.to_s.downcase.gsub("_", " ") }
    value = @row[index] if index

    self.instance_variable_set("@#{field}", value)
    self.class.class_eval { attr_reader field }
  end

  def tags_list
    @tags.to_s.strip.split(/[\s,|]+/)
  end

end
