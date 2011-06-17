class Job::Settlement
  class << self
    def run
      range = Settlement.range_for(DateTime.now)
      settle_performances_in(range)
      settle_donations_in(range)
    end

    def settle_performances_in(range)
      AthenaPerformance.in_range(range[0], range[1]).each do |performance|
        settlement = Settlement.new(performance.settleables, performance.organization.bank_account)
        settlement.submit
      end
    end

    def settle_donations_in(range)
      AthenaOrder.in_range(range[0], range[1]).group_by(&:organization_id).each do |organization_id, order_set|
        donations = order_set.collect(&:all_donations).flatten
        organization = order_set.first.organization

        settlement = Settlement.new(donations, organization.bank_account)
        settlement.submit
      end
    end
  end
end