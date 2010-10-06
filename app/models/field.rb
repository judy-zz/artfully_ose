class Field < AthenaResource::Base
  self.site = ArtfulLy::Application.config.tickets_site
  self.format = :json
  self.prefix = '/tickets/'

  schema do
    integer :id
    string  :name
    #TODO: Change this when Rails relases ARes updates
    # boolean :strict
    string :strict
    string :valueType
  end
end
