class FA::Session < ActiveResource::Base
  self.site = "http://staging.api.fracturedatlas.org"

  self.auth_type = :digest
  self.user = 'artful.ly'
  self.password = '36659e2cd56b2cef6b4e2b4c4196e2df'

  schema do
    attribute :user, :string
  end

  def self.api_test
    new.tap do |session|
      connection.get("/sessions.xsd", session.class.headers).tap do |response|
        ap response
      end
    end
  end

  def self.with_credentials(email, password, &block)
    new.tap do |session|
      session.user = FA::User.new({:email => email, :password => password})
      block.call(session) if block_given?
    end
  end

  def self.authenticate(email, password)
    with_credentials(email, password) do |session|
      session.authenticate
    end
  end

  def authenticate
    begin
      connection.post("/sessions.xml", encode, self.class.headers).tap do |response|
        self.id = id_from_response(response)
        reload
      end
    rescue ActiveResource::ForbiddenAccess => e
      ap e
    end
  end

  def authenticated?
    true
  end
end

class FA::User < ActiveResource::Base
  self.site = "http://staging.api.fracturedatlas.org"

  schema do
    attribute 'username', :string
    attribute 'email',    :string
    attribute 'password', :string
  end
end