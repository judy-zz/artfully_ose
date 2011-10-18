class Ticket::Template
  def initialize(attrs = {})
    @attributes = attrs
  end

  def collect; self; end

  def flatten; self; end

  def attributes
    @attributes
  end

  def update_attributes(attrs)
    @attributes.merge!(attrs)
  end

  def build
    count = @attributes.delete(:count).to_i
    count.times.collect { Ticket.new(attributes) }
  end
end