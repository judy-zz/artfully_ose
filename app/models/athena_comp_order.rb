class AthenaCompOrder < AthenaOrder
  self.site = Artfully::Application.config.orders_component
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'orders'
  self.collection_name = 'orders'

  schema do
    attribute :person_id,       :integer
    attribute :organization_id, :integer
    attribute :customer_id,     :string
    attribute :transaction_id,  :string
    attribute :parent_id,       :string
    attribute :price,           :integer
    attribute :details,         :string
    attribute :timestamp,       :string

    #pseudo people
    attribute :first_name,      :string
    attribute :last_name,       :string
    attribute :email,           :string

    #fa attributes
    attribute :check_no,    :string
  end

  def ticket_details
    "#{num_tickets} ticket(s) comped"
  end

  def <<(products)
    self.items += Array.wrap(products).collect { |product| AthenaItem.for(product) }
    self.items.each do |item|
      item.to_comp!
    end
  end

end