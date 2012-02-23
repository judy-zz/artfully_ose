class ExternalOrder < Order
  belongs_to :reseller_order, :class_name => "Reseller::Order", :foreign_key => "reseller_order_id"
  
  def location
    "Reseller"
  end
end