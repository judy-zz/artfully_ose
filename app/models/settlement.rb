class Settlement
  def initialize(items, bank_account)
    @items = Array.wrap(items)
    @memo = "Lorem Ipsum memo"
    @request = ACH::Request.for(@items.sum(&:net), bank_account, @memo)
  end

  def submit
    @request.submit
    # TODO: Mark items as settled.
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
end