class Ticket < AthenaResource::Base
  self.site = Artfully::Application.config.tickets_site
  self.format = :json

  def self.load_schema
    new_schema = {}
    fields = Field.find(:all)
    #TODO: Use this when ARes gets updated.
    #fields.each { |field| new_schema[field.name] = field.valueType.downcase.to_sym } unless fields.nil?
    fields.each { |field| new_schema[field.name] = :string } unless fields.nil?
    self.schema = new_schema
  end
  
  def self.schema(&block)
    unless block_given?
      load_schema if super.nil?
    end

    super
  end
 
  def to_athena_json
    props = self.attributes.dup
    props.delete :id
    props.delete :name
    props.each_key { |key| } 
    {:id => self.id, :name => self.name, :props => props}.to_json
  end

  def self.generate_for_performance(performance, quantity, price)
    tickets = []
    params = {  :PRICE        => price,
                :VENUE        => performance.venue,
                :PERFORMANCE  => performance.performed_on,
                :EVENT        => performance.title } 

    quantity.to_i.times do
      tickets << Ticket.create(params)
    end
    tickets
  end
end
