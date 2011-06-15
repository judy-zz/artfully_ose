class Job::Settlement
  class << self
    def run
      range = Settlement.range_for(DateTime.now)
      settle_performances_in(range)
      settle_donations_in(range)
    end

    def settle_performances_in(range)
      AthenaPerformance.in_range(range).each do |performance|
        settlement = Settlement.new(performance.settleables, performance.organization.bank_account)
        settlement.submit
      end
    end

    def settle_donations_in(range)
      AthenaOrder.in_range(range).each do |order|
        order.all_donations.each do |donation|
          settlement = Settlement.new(donation, donation.order.organization.bank_account)
          settlement.submit
        end
      end
    end
  end
end