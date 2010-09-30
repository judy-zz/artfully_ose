class Ticket < AthenaResource::Base
  self.site = 'http://localhost'
  self.format = :json

  def to_athena_json
    props = self.attributes.dup
    props.delete :id
    props.delete :name
    props.each_key { |key| } 
    {:id => self.id, :name => self.name, :props => props}.to_json
  end
end
