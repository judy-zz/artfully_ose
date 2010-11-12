class Athena::Customer
  include ActiveModel::Validations

  # Note: This is used to provide a more ruby-friendly set of accessors that will still serialize properly.
  def self.aliased_attr_accessor(*accessors)
    attr_reader :attributes
    accessors.each do |attr|
      attr = attr.to_s.camelize(:lower)
      class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        def #{attr}() @attributes['#{attr}'] end
        def #{attr}=(#{attr}) @attributes['#{attr}'] = #{attr} end
        def #{attr.underscore}() @attributes['#{attr}'] end
        def #{attr.underscore}=(#{attr}) @attributes['#{attr}'] = #{attr} end
      RUBY_EVAL
    end
  end

  aliased_attr_accessor :firstName, :lastName, :company, :phone, :email
  validates_presence_of :first_name, :last_name, :email

  def initialize(attrs = {})
    @attributes = {}.with_indifferent_access
    load(attrs)
  end

  # TODO: Check type of attrs, reject non-attributes
  def load(attrs)
    attrs.each do |attr, value|
      self.send(attr.to_s+'=', value)
    end
  end

  def as_json(options = nil)
    @attributes.as_json
  end
end
