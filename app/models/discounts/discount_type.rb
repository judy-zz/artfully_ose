class DiscountType
  attr_accessor :properties

  def initialize(properties)
    @properties = properties
  end
  
  def apply_discount_to_cart(*args)
    raise "This method has not been defined in child class!"
  end
end
