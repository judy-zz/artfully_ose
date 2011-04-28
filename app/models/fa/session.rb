class FA::Session < FA::Base
  schema do
    attribute :user, :string
  end

  def self.authenticate(user)
    session = new(:user => user)
    session.authenticate
    session
  end

  def authenticate
    begin
      connection.post("/sessions.xml", to_xml(), self.class.headers).tap do |response|
        self.id = id_from_response(response)
      end
      @authenticated = true
      #reload
    rescue ActiveResource::ForbiddenAccess => e
      @authenticated = false
    end
  end

  def authenticated?
    @authenticated || false
  end
end