class AthenaCompOrder < AthenaOrder
  self.site = Artfully::Application.config.orders_component
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'orders'
  self.collection_name = 'orders'

  def initialize(attributes = {})
    super(attributes)
  end
  
  def <<(products)
    self.items += Array.wrap(products).collect { |product| AthenaItem.for(product) }
    self.items.each do |item|
      item.to_comp!
    end
  end
  
end