class AthenaCustomer < AthenaResource::Base

  self.site = Artfully::Application.config.tickets_site
  self.prefix = '/payments/'
  self.collection_name = 'customers'
  self.element_name = 'customers'

  schema do
    attribute 'firstName',  :string
    attribute 'lastName',   :string
    attribute 'company',    :string
    attribute 'phone',      :string
    attribute 'email',      :string
  end

  def load(attributes)
    fixed = {}
    attributes.each do |key, value|
      fixed[key.camelize(:lower)] = attributes.delete(key) if known_attributes.include?(key.camelize(:lower))
    end
    super(attributes.merge(fixed))
  end

  # Note: This is used to provide a more ruby-friendly set of accessors that will still serialize properly.
  def self.aliased_attr_accessor(*accessors)
    attr_reader :attributes
    accessors.each do |attr|
      attr = attr.to_s.camelize(:lower)
      class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        def #{attr}()                     @attributes['#{attr}'] end
        def #{attr}=(#{attr})             @attributes['#{attr}'] = #{attr} end
        def #{attr.underscore}()          @attributes['#{attr}'] end
        def #{attr.underscore}=(#{attr})  @attributes['#{attr}'] = #{attr} end
      RUBY_EVAL
    end
  end

  aliased_attr_accessor :firstName, :lastName, :company, :phone, :email
  validates_presence_of :first_name, :last_name, :email

  def as_json(options = nil)
    @attributes.as_json
  end
end
