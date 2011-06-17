class Settlement < AthenaResource::Base
  self.site = Artfully::Application.config.orders_component
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'settlements'
  self.collection_name = 'settlements'

  schema do
    attribute :id,              :string
    attribute :transaction_id,  :string
    attribute :created_at,      :string

    attribute :gross,           :integer
    attribute :net,             :integer
    attribute :items_count,     :integer
  end

  def initialize(*)
    super
    self.created_at = Time.now
  end

  def items
    @items ||= find_items
  end

  def items=(items)
    @items = items
  end

  def self.submit(items, bank_account)
    items = Array.wrap(items)
    memo = "Lorem Ipsum memo"
    transaction_id = send_request(items, bank_account, memo)

    for_items(items) do |settlement|
      settlement.transaction_id = transaction_id
      settlement.save!
      AthenaItem.settle(items)
    end
  end

  def self.for_items(items)
    new.tap do |settlement|
      settlement.items          = items
      settlement.gross          = items.sum(&:price)
      settlement.realized_gross = items.sum(&:realized_price)
      settlement.net            = items.sum(&:net)
      settlement.items_count    = items.size

      yield(settlement) if block_given?
    end
  end

  def self.range_for(now)
    start = start_from(now.beginning_of_day)
    stop  = offset_from(start)
    [ start, stop ]
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
    items ||= AthenaItem.find_by_settlement(self)
  end

  def self.send_request(items, bank_account, memo)
    request = ACH::Request.for(items.sum(&:net), bank_account, memo)
    request.submit
  end
end