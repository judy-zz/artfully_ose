class Contribution
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_reader :contributor, :person_id, :subtype, :amount, :occurred_at, :details, :organization_id, :creator_id, :order, :action

  def initialize(params = {})
    load(params)
    @contributor = find_contributor
  end

  def save(order_klass = ApplicationOrder, &block)
    @order  = build_order(order_klass)
    Order.transaction do
      @order.save!
      @order.update_attribute(:created_at, @occurred_at)

      @item   = build_item(@order, @amount)
      @item.save!

      @action = build_action
      @action.save!
    end
    yield(self) if block_given?
    @order
  end

  def has_contributor?
    contributor.present?
  end

  def persisted?
    false
  end

  private

  def load(params)
    @subtype         = params[:subtype]
    @amount          = params[:amount]
    @organization_id = params[:organization_id]
    @occurred_at     = ActiveSupport::TimeZone.create(Organization.find(@organization_id).time_zone).parse(params[:occurred_at]) if params[:occurred_at].present?
    @details         = params[:details]
    @person_id       = params[:person_id]
    @creator_id      = params[:creator_id]
  end

  def find_contributor
    Person.find(@person_id) unless @person_id.blank?
  end

  def build_action
    params = {
      :subtype => @subtype,
      :occurred_at => @occurred_at,
      :details => @details
    }
    person = Person.find(@person_id)
    action = Action.create_of_type("give")
    action.set_params(params, person)
    action.subject = @order
    action.organization_id = @organization_id
    return action
  end

  def build_order(order_klass = ApplicationOrder)
    attributes = {
      :person_id       => @person_id,
      :organization_id => @organization_id,
      :details         => @details
    }

    order = order_klass.new(attributes).tap do |order|
      order.skip_actions = true
    end
  end

  def build_item(order, price)
    Item.new({
      :order_id       => order.id,
      :product_type   => "Donation",
      :state          => "settled",
      :price          => price,
      :realized_price => price,
      :net            => price
    })
  end
end