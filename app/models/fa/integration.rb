class FA::Integration < FA::Base
  schema do
    attribute 'member_id',  :string
    attribute 'partner_id',  :string
  end
  
  def initialize(user, artfully_organization)
    super()
    attributes['member_id'] = user.member_id
    attributes['partner_id'] = artfully_organization.id
  end

  def save
    connection.post("/members/integrations.xml", to_xml(:dasherize => false), self.class.headers).tap do |response|
      self.id = id_from_response(response)
    end
  end

end