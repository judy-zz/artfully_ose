class Order < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  belongs_to :person
  belongs_to :organization

  belongs_to :parent, :class_name => "Order"
  has_many :children, :class_name => "Order"

  has_many :items

  attr_accessor :skip_actions

  validates_presence_of :person_id, :unless => lambda { person_information_present? }
  validates_presence_of :organization_id

  after_create :create_purchase_action, :unless => :skip_actions
  after_create :create_donation_actions, :unless => :skip_actions

  scope :before, lambda { |time| where("created_at < ?", time) }
  scope :after,  lambda { |time| where("created_at > ?", time) }
  scope :in_range, lambda { |start, stop| after(start).before(stop) }

  def person_information_present?
    # !(first_name.nil? || last_name.nil? || email.nil?)
  end

  def total
    all_items.inject(0) {|sum, item| sum + item.price.to_i }
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
    self.items << Array.wrap(products).collect { |product|  Item.for(product) }
  end

  def payment
    AthenaPayment.new(:transaction_id => transaction_id)
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

  def items_detail
    num_tickets = 0
    sum_donations = 0

    all_items.each{ |item|
      if item.ticket?
        num_tickets += 1
      elsif item.donation?
        sum_donations += item.price.to_i
      end }

    tickets = "#{num_tickets} ticket(s)"
    donations = "$#{sum_donations/100.00} donation"

    if num_tickets == 0
      result = "#{[donations].to_sentence}"
    elsif sum_donations == 0.0
      result = "#{[tickets].to_sentence}"
    else
      result = "#{[tickets, donations].to_sentence}"
    end

    result.to_sentence
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
    "#{num_tickets} ticket(s)"
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

  private

    def merge_and_sort_items
      items.concat(children.collect(&:items).flatten)
    end

    def create_purchase_action
      unless all_tickets.empty?
        action                 = PurchaseAction.new
        action.person          = person
        action.subject         = self
        action.organization_id = organization.id
        action.details         = ticket_details
        action.occurred_at     = created_at
        action.subtype  = "Purchase"

        logger.debug("Creating action: #{action}, with org id #{action.organization_id}")
        logger.debug("Action: #{action.attributes}")
        action.save!
        action
      end
    end

    def create_donation_actions
      items.select(&:donation?).collect do |item|
        action                 = DonationAction.new
        action.person          = person
        action.subject         = item.product
        action.organization_id = organization.id
        action.details         = donation_details
        action.occurred_at     = created_at
        action.subtype  = "Donation"
        action.save!
        action
      end
    end
end