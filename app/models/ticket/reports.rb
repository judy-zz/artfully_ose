module Ticket::Reports
  class Base
    def initialize(parent)
      @parent = parent
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
      tickets.sold.sold_before(Time.now.beginning_of_day).count
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
      tickets.comped.sold_before(Time.now.beginning_of_day).count
    end

    def played
      tickets.comped.played.count
    end
  end

  class Sales < Base
    def total; end
    def today; end
    def played; end
    def advance; end
  end

  class Potential < Base
    def original; end
    def remaining; end
  end
end