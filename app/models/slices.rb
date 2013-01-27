class Slices
  cattr_accessor :payment_method_proc, 
                 :ticket_type_proc, 
                 :order_location_proc,
                 :discount_code_proc

  self.payment_method_proc = Proc.new do |items|
    payment_method_map = {}
    items.each do |item|
      item_array = payment_method_map[item.order.payment_method]
      item_array ||= []
      item_array << item
      payment_method_map[item.order.payment_method] = item_array
    end
    payment_method_map
  end

  self.ticket_type_proc = Proc.new do |items|
    ticket_type_map = {}
    items.each do |item|
      item_array = ticket_type_map[item.product.section.name]
      item_array ||= []
      item_array << item
      ticket_type_map[item.product.section.name] = item_array
    end
    ticket_type_map
  end

  self.order_location_proc = Proc.new do |items|
    order_location_map = {}
    items.each do |item|
      item_array = order_location_map[item.order.location]
      item_array ||= []
      item_array << item
      order_location_map[item.order.location] = item_array
    end
    order_location_map
  end

  self.discount_code_proc = Proc.new do |items|
    discounts_code_map = {}
    items.each do |item|
      code = item.discount.try(:code) || "NO DISCOUNT"
      item_array = discounts_code_map[code]
      item_array ||= []
      item_array << item
      discounts_code_map[code] = item_array
    end
    discounts_code_map
  end
end