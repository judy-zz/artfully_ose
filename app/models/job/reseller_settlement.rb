class Job::ResellerSettlement < Job::Base
  class << self
    def run
      range = ResellerSettlement.range_for(DateTime.now)
      self.settle_shows_in(range)
    end

    def settle_shows_in(range)
      logger.info "Settling shows..."
      settlements = []
      Organization.find_in_batches do |organizations|
        organizations.each do |organization|
          begin
            items = organization.items_sold_as_reseller_during(range)
            if items.length > 0
              settlements << ResellerSettlement.submit(organization.id, items, organization.bank_account)
            end
          rescue Exception => e
            logger.error e.backtrace
          end
        end
      end

      AdminMailer.reseller_settlement_summary(settlements).deliver
    end
  end
end
