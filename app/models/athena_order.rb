class AthenaOrder < AthenaResource::Base
  self.site = Artfully::Application.config.orders_component
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'orders'
  self.collection_name = 'orders'

  schema do
    attribute :person_id,       :integer
    attribute :organization_id, :integer
    attribute :customer_id,     :string
    attribute :price,           :integer
  end

  def person
    @person ||= find_person
  end

  def person=(person)
    if person.nil?
      @person = person_id = person
      return
    end

    raise TypeError, "Expecting an AthenaPerson" unless person.kind_of? AthenaPerson
    @person, self.person_id = person, person.id
  end

  def organization
    @organization ||= Organization.find(organization_id)
  end

  def organization=(org)
    raise TypeError, "Expecting an Organization" unless org.kind_of? Organization
    org.save unless org.persisted?
    @organization, self.organization_id = org, org.id
  end

  def customer
    @customer ||= find_customer
  end

  def customer=(customer)
    if customer.nil?
      @customer = customer_id = customer
      return
    end

    raise TypeError, "Expecting an AthenaCustomer" unless customer.kind_of? AthenaCustomer
    @customer, self.customer_id = customer, customer.id
  end

  def items
    @items ||= find_items
  end

  def items=(items)
    @items = items
  end

  def save
    was_saved = super
    items.each { |item| item.order_id = self.id; item.save } if was_saved
    was_saved
  end

  private
    def find_person
      return if self.person_id.nil?

      begin
        AthenaPerson.find(self.person_id)
      rescue ActiveResource::ResourceNotFound
        update_attribute!(:person_id, nil)
        return nil
      end
    end

    def find_customer
      return if self.customer_id.nil?

      begin
        AthenaCustomer.find(self.customer_id)
      rescue ActiveResource::ResourceNotFound
        update_attribute!(:customer_id, nil)
        return nil
      end
    end

    def find_items
      items ||= AthenaItem.find_by_order(self)
    end
end