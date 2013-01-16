module Ticket::Reports
  class Base
    def initialize(parent)
      @parent = parent
    end

    def self.reporting_methods
      self.public_instance_methods - Object.public_instance_methods
    end

    private

    def parent
      @parent
    end

    def tickets
      parent.send(:tickets)
    end
  end

  class Available < Base
    def total
      tickets.on_sale.count
    end
  end

  class Sold < Base
    def total
      tickets.sold.count
    end

    def today
      tickets.sold_after(Time.now.beginning_of_day).count
    end

    def played
      tickets.sold.played.count
    end
  end

  class Comped < Base
    def total
      tickets.comped.count
    end

    def today
      tickets.comped.sold_after(Time.now.beginning_of_day).count
    end

    def played
      tickets.comped.played.count
    end
  end

  class Sales < Base
    def total
      tickets.sold.sum(:sold_price)
    end

    def today
      tickets.sold_after(Time.now.beginning_of_day).sum(:sold_price)
    end

    def played
      tickets.sold.played.sum(:sold_price)
    end

    def advance
      tickets.sold.unplayed.sum(:sold_price)
    end
  end

  class Potential < Base
    def original
      tickets.sum(:price)
    end

    def remaining
      tickets.unsold.sum(:price)
    end
  end
end