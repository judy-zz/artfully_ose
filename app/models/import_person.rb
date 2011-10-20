class ImportPerson

  # Define the list of fields known about a person and the various column names
  # that might be used for that field.
  FIELDS = {
    :email            => [ "Email", "Email address" ],
    :first            => [ "First", "First name" ],
    :last             => [ "Last", "Last name" ],
    :company          => [ "Company", "Company name" ],
    :address1         => [ "Address1", "Address 1" ],
    :address2         => [ "Address2", "Address 2" ],
    :city             => [ "City" ],
    :state            => [ "State" ],
    :zip              => [ "Zip", "Zip code" ],
    :country          => [ "Country" ],
    :phone1_type      => [ "Phone 1 type" ],
    :phone1_number    => [ "Phone 1", "Phone 1 number" ],
    :phone2_type      => [ "Phone 2 type" ],
    :phone2_number    => [ "Phone 2", "Phone 2 number" ],
    :phone3_type      => [ "Phone 3 type" ],
    :phone3_number    => [ "Phone 3", "Phone 3 number" ],
    :website          => [ "Website" ],
    :twitter_username => [ "Twitter", "Twitter handle", "Twitter username" ],
    :facebook_page    => [ "Facebook", "Facebook url", "Facebook address", "Facebook page" ],
    :linkedin_page    => [ "LinkedIn", "LinkedIn url", "LinkedIn address", "LinkedIn page" ],
    :tags             => [ "Tags" ]
  }

  def initialize(headers, row)
    @headers = headers
    @row = row

    FIELDS.each do |field, columns|
      columns.each do |column|
        load_value field, column
      end
    end
  end

  def load_value(field, column)
    index = @headers.index { |h| h.to_s.downcase.strip == column.downcase }
    value = @row[index] if index
    exist = self.instance_variable_get("@#{field}")

    if exist.blank?
      self.instance_variable_set("@#{field}", value)
      self.class.class_eval { attr_reader field }
    end
  end

  def tags_list
    @tags.to_s.strip.split(/[\s,|]+/)
  end

end
