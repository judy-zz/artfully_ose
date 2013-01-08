class DiscountsReport
  attr_accessor :discount, :start_date, :end_date

  def initialize(discount_code, start_date, end_date)
    self.discount = Discount.where(:id => discount_code).includes(:tickets).first
    self.discount ||= Discount.where(:code => discount_code).includes(:tickets).first
  
    self.start_date = start_date
    self.end_date = end_date

    @items = Item.includes(:order => :person, :show => :event).where(:product_id => self.discount.tickets).where('orders.created_at' => self.start_date..self.end_date).group('items.order_id')
    #@items = Item.includes(:order => :person, :show => :event).where(:product_id => discount.tickets).where('orders.created_at' => self.start_date..self.end_date)
  end


end