class ParsedRow
  
  attr_accessor :row

  SHARED_FIELDS = {
    :first            => [ "First name", "First" ],
    :last             => [ "Last name", "Last" ],
    :email            => [ "Email", "Email address" ]
  }

  PEOPLE_FIELDS = SHARED_FIELDS.merge( {
    :company          => [ "Company name", "Company" ],
    :address1         => [ "Address 1", "Address1" ],
    :address2         => [ "Address 2", "Address2" ],
    :city             => [ "City" ],
    :state            => [ "State" ],
    :zip              => [ "Zip", "Zip code" ],
    :country          => [ "Country" ],
    :phone1_type      => [ "Phone1 type", "Phone 1 type" ],
    :phone1_number    => [ "Phone1 number", "Phone 1", "Phone 1 number", "Phone1" ],
    :phone2_type      => [ "Phone2 type", "Phone 2 type" ],
    :phone2_number    => [ "Phone2 number", "Phone 2", "Phone 2 number", "Phone2" ],
    :phone3_type      => [ "Phone3 type", "Phone 3 type" ],
    :phone3_number    => [ "Phone3 number", "Phone 3", "Phone 3 number", "Phone3" ],
    :website          => [ "Website" ],
    :twitter_username => [ "Twitter handle", "Twitter", "Twitter username" ],
    :facebook_page    => [ "Facebook url", "Facebook", "Facebook address", "Facebook page" ],
    :linkedin_page    => [ "Linked in url", "LinkedIn url", "LinkedIn", "LinkedIn address", "LinkedIn page" ],
    :tags             => [ "Tags" ],
    :person_type      => [ "Person Type" ]    
  })
  
  EVENT_FIELDS = SHARED_FIELDS.merge( {
    :event_name       => [ "Event", "Event Name" ],
    :venue_name       => [ "Venue", "Venue Name" ],
    :show_date        => [ "Show", "Show Date" ],
    :amount           => [ "Amount", "Dollar Amount" ],
    :payment_method   => [ "Method Of Payment", "Method of Payment", "Payment Method" ],
    :order_date       => [ "Order Date" ]
  })
  
  FIELDS = PEOPLE_FIELDS.merge(EVENT_FIELDS)

  # Enumerated columns default to the last value if the data value is not valid.
  #
  # With the way the current code is using instance_variable_get, columns that use an enumeration
  # cannot accept multiple column names.  We can only have one column name map to person_type
  ENUMERATIONS = {
    :person_type => [ "Individual", "Corporation", "Foundation", "Government", "Other" ]
  }

  def self.parse(headers, row)
    ParsedRow.new(headers, row)
  end
  
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
      value = check_enumeration(field, value)

      self.instance_variable_set("@#{field}", value)
      
      #skip amount because we have to parse it
      unless field.eql? :amount
        self.class.class_eval { attr_reader field }
      end
    end
  end

  def tags_list
    @tags.to_s.strip.gsub(/\s+/, "-").split(/[,|]+/)
  end

  def check_enumeration(field, value)
    if enum = ENUMERATIONS[field]      
      if index = enum.map(&:downcase).index(value.to_s.downcase)
        enum[index]
      else
        enum.last
      end
    else
      value
    end
  end
  
  def amount
    ((@amount.to_f || 0) * 100).to_i
  end
  
  def unparsed_amount
    @amount
  end
  
  def importing_event?
    !self.event_name.blank?
  end
  
  def person_attributes
      {:email           => self.email,
      :first_name      => self.first,
      :last_name       => self.last,
      :company_name    => self.company,
      :website         => self.website,
      :twitter_handle  => self.twitter_username,
      :facebook_url    => self.facebook_page,
      :linked_in_url   => self.linkedin_page,
      :person_type     => self.person_type}
  end

end
