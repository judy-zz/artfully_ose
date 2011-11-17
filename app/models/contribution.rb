class Contribution
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_reader :contributor, :person_id, :subtype, :amount, :occurred_at, :details, :organization_id

  def initialize(params = {})
    load(params)
    @contributor = find_contributor
  end

  def save
    @order  = build_order
    @order.save!

    @item   = build_item(@order, @amount)
    @item.save!

    @action = build_action
    @action.save!
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
    @person_id  = params[:person_id]
  end

  def find_contributor
    Person.find(@person_id) unless @person_id.blank?
  end

  def build_action
    GiveAction.new({
      :subtype          => @subtype,
      :organization_id  => @organization_id,
      :occurred_at      => @occurred_at,
      :details          => @details,
      :person_id        => @person_id
    })
  end

  def build_order
    attributes = {
      :person_id       => @person_id,
      :organization_id => @organization_id
    }

    Order.new(attributes).tap do |order|
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