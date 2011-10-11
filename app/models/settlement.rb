require_or_load 'ach/exceptions'

class Settlement < AthenaResource::Base
  self.site = Artfully::Application.config.orders_component
  self.element_name = 'settlements'
  self.collection_name = 'settlements'

  schema do
    attribute :id,                :string
    attribute :transaction_id,    :string
    attribute :ach_response_code, :string
    attribute :fail_message,      :string
    attribute :success,           :string
    attribute :organization_id,   :string
    attribute :performance_id,    :string
    attribute :created_at,        :string

    attribute :gross,             :integer
    attribute :realized_gross,    :integer
    attribute :net,               :integer
    attribute :items_count,       :integer
  end

  def initialize(*)
    super
    self.created_at ||= Time.now
  end

  def items
    @items ||= find_items
  end

  def items=(items)
    @items = items
  end

  def self.submit(organization_id, items, bank_account, performance_id=nil)
    items = Array.wrap(items)

    if items.empty?
      # This is considered a success.  No items, no money to transfer, we're done
      ach_response_code = nil
      success = true
      fail_message = "There are no items for this settlement"
    elsif bank_account.nil?
      ach_response_code = nil
      success = false
      fail_message = "This organization has no bank account"
    else
      begin
        transaction_id = send_request(items, bank_account, "Artful.ly Settlement #{Date.today}")
        ach_response_code = ACH::Request::SUCCESS
        fail_message = ""
        success = true
      rescue ACH::ClientError => e
        ach_response_code = e.to_s
        fail_message = "#{e.backtrace.inspect}"
        success = false
      rescue Exception => e
        ach_response_code = e.to_s
        fail_message = "#{e.to_s} #{e.backtrace.inspect}"
        success = false
      end
    end

    for_items(items) do |settlement|
      settlement.ach_response_code = ach_response_code
      settlement.transaction_id    = transaction_id
      settlement.organization_id   = organization_id
      settlement.performance_id    = performance_id
      settlement.fail_message      = fail_message
      settlement.success           = success
      settlement.save!
      if settlement.success?
        AthenaItem.settle(items, settlement)
      end

      settlement
    end
  end

  def self.for_items(items)
    new.tap do |settlement|
      settlement.items          = items
      settlement.gross          = items.sum { |i| i.price.to_i }
      settlement.realized_gross = items.sum { |i| i.realized_price.to_i }
      settlement.net            = items.sum { |i| i.net.to_i }
      settlement.items_count    = items.size

      yield(settlement) if block_given?
    end
  end

  def success?
    ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include? success
  end

  def self.range_for(now)
    start = start_from(now.beginning_of_day)
    stop  = offset_from(start)
    [ start, stop ]
  end

  def self.in_range(start, stop, org_id=nil)
    start = "gt#{start.xmlschema}"
    stop = "lt#{stop.xmlschema}"

    org_query = "organizationId=eq#{org_id}&" unless org_id.nil?

    instantiate_collection(query("#{org_query}createdAt=#{start}&createdAt=#{stop}"))
  end

  private
  class << self
    def start_from(now)
      business_days = 3
      while(business_days > 0) do
        now -= 1.day
        business_days -= 1 unless weekend?(now)
      end
      now
    end

    def offset_from(start)
      stop = start + 1.day
      stop += 2.days if stop.wday == 6

      end_of_day_before(stop)
    end

    def end_of_day_before(day)
      (day - 1.day).end_of_day
    end

    def weekend?(day)
      [ 0, 6 ].include?(day.wday)
    end

    def weekend_offset(day)
      weekend?(day) ? 2.days : 0
    end
  end

  def find_items
    return [] if new_record?
    items ||= AthenaItem.find_by_settlement_id(self.id)
  end

  def self.send_request(items, bank_account, memo)
    request = ACH::Request.for(items.sum{ |i| i.net.to_i }, bank_account, memo)
    request.submit
  end
end