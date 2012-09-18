#Subclasses (and their type) should speak to the *location* or *nature* of the order, not the contents of the items
# WebOrder, BoxOfficeOrder for example.  NOT DonationOrder, since orders may contain multiple different item types
class Order < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  include ArtfullyOseHelper
  include Ext::Integrations::Order
  
  #This is a lambda used to by the items to calculate their net
  attr_accessor :per_item_processing_charge

  attr_accessible :person_id, :organization_id, :person, :organization, :details

  belongs_to :person
  belongs_to :organization
  belongs_to :parent, :class_name => "Order", :foreign_key => "parent_id"
  has_many :children, :class_name => "Order", :foreign_key => "parent_id"
  has_many :items
  has_many :actions, :foreign_key => "subject_id"

  attr_accessor :skip_actions

  set_watch_for :created_at, :local_to => :organization  
  set_watch_for :created_at, :local_to => :self, :as => :admins

  validates_presence_of :person_id
  validates_presence_of :organization_id

  after_create :create_purchase_action, :unless => :skip_actions
  after_create :create_donation_actions, :unless => :skip_actions

  default_scope :order => 'orders.created_at DESC'
  scope :before, lambda { |time| where("orders.created_at < ?", time) }
  scope :after,  lambda { |time| where("orders.created_at > ?", time) }
  scope :imported, where("fa_id IS NOT NULL")
  scope :not_imported, where("fa_id IS NULL")
  scope :artfully, where("transaction_id IS NOT NULL")

  def self.in_range(start, stop, organization_id = nil)
    query = after(start).before(stop).includes(:items, :person, :organization).order("created_at DESC")
    if organization_id.present?
      query.where('organization_id = ?', organization_id)
    else
      query
    end
  end
  
  def artfully?
    !transaction_id.nil?
  end
  
  def location
    ""
  end

  def total
    all_items.inject(0) {|sum, item| sum + item.total_price.to_i }
  end

  def nongift_amount
    all_items.inject(0) {|sum, item| sum + item.nongift_amount.to_i }
  end

  def tickets
    items.select(&:ticket?)
  end

  def donations
    items.select(&:donation?)
  end

  def for_organization(org)
    self.organization = org
  end

  def <<(products)
    self.items << Array.wrap(products).collect { |product|  Item.for(product, @per_item_processing_charge) }
  end

  def payment
    CreditCardPayment.new(:transaction_id => transaction_id)
  end

  def record_exchange!
    items.each do |item|
      item.to_exchange!
    end
  end

  def all_items
    merge_and_sort_items
  end

  def all_tickets
    all_items.select(&:ticket?)
  end

  def all_donations
    all_items.select(&:donation?)
  end

  def settleable_donations
    all_donations.reject(&:modified?)
  end

  def refundable_items
    items.select(&:refundable?)
  end

  def exchangeable_items
    items.select(&:exchangeable?)
  end

  def num_tickets
    all_tickets.size
  end

  def has_ticket?
    items.select(&:ticket?).present?
  end

  def has_donation?
    items.select(&:donation?).present?
  end

  def sum_donations
    all_donations.collect{|item| item.price.to_i}.sum
  end

  def ticket_details
    pluralize(num_tickets, "ticket") + " to " + all_tickets.first.show.event.name
  end
  
  def to_comp!
    items.each do |item|
      item.to_comp!
    end
  end

  def is_fafs?
    !fa_id.nil?
  end

  def donation_details
    if is_fafs?
      o = Organization.find(organization_id)
      "#{number_as_cents sum_donations} donation via Fractured Atlas for the benefit of #{o.fiscally_sponsored_project.name}"
    else
      "#{number_as_cents sum_donations} donation"
    end
  end

  def returnable_items
    items.select { |i| i.returnable? and not i.refundable? }
  end
  
  def ticket_summary
    summary = TicketSummary.new
    items.select(&:ticket?).each do |item|
      summary << item.product
    end
    summary
  end

  def credit?
    payment_method.eql? 'Credit card'
  end
  
  def time_zone
    "Eastern Time (US & Canada)"
  end

  private

    #this used to do more.  Now it only does this
    def merge_and_sort_items
      items
    end

    def create_purchase_action
      unless all_tickets.empty?
        action                  = GetAction.new
        action.person           = person
        action.subject          = self
        action.organization     = organization
        action.details          = ticket_details
        action.occurred_at      = created_at
        action.subtype          = "Purchase"

        action.save!
        action
      end
    end

    def create_donation_actions
      items.select(&:donation?).collect do |item|
        action                    = GiveAction.new
        action.person             = person
        action.subject            = self
        action.organization_id    = organization.id
        action.details            = donation_details
        action.occurred_at        = created_at
        action.subtype            = "Donation"
        action.save!
        action
      end
    end
end
