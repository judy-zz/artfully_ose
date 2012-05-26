class FA::Session < FA::Base
  schema do
    attribute :user, :string
  end

  def self.authenticate(user)
    session = new(:user => user)
    session.authenticate
    session
  end
  
  #
  # HACK: This is a deep, deep hack which overrides functionality introcused in ActiveResource 3.1
  # AR 3.1 won't even return the id of a record for the find method if the record doesn't 
  # report that it has persisted.  This being FA authentication, we're not persisting anything,
  # just authenticating.  So, we hack persisted? here so that the reload call in authenticate will work
  #
  # See: http://rubydoc.info/docs/rails/3.1.1/ActiveModel/Conversion#to_key-instance_method
  #
  def persisted?
    true
  end

  def authenticate
    begin
      connection.post("/sessions.xml", to_xml(), self.class.headers).tap do |response|
        self.id = id_from_response(response)
      end
      @authenticated = true
      reload
    rescue ActiveResource::ForbiddenAccess => e
      @authenticated = false
    end
  end

  def authenticated?
    @authenticated || false
  end
end