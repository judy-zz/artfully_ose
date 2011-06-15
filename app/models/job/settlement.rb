class Job::Settlement
  class << self
    def run
      range = Settlement.range_for(DateTime.now)
      settle_performances_in(range)
    end

    def settle_performances_in(range)
      AthenaPerformance.in_range(range).each do |performance|
        settlement = Settlement.new(performance.settleables, performance.organization.bank_account)
        settlement.submit
      end
    end
  end
end