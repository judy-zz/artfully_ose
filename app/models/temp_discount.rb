# only exsist for mockuping up the discount form
# remove after Discount and DiscountSections model is created

class TempDiscount < Event
  attr_accessor :code, :minimum_purchase, :maximum_purchase, :show_ids

  has_many :discount_sections
end

class DiscountSection < Section
  attr_accessor :temp_discount_id, :section, :section_id, :limit, :unlimited_capacity

  attr_accessible :section
end