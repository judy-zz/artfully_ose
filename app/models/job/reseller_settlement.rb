class Job::ResellerSettlement < Job::Base
  class << self
    def run
      range = (DateTime.now.beginning_of_month.to_date .. DateTime.now.end_of_month.to_date)
      settle_shows_in(range)
    end

    def settle_shows_in(range)
      logger.info "Settling shows..."
      shows_to_settle = Show.in_range(range.first, range.last).reject(&:event_deleted?).reject(&:free?)
      settlements = []

      shows_to_settle.each do |show|
        logger.info "Settling #{show.event.name}, #{show.datetime_local_to_organization}"

        begin
          show.reseller_settleables.each do |reseller, items|
            logger.error "#{show.organization.name} does not have a bank account." if reseller.bank_account.nil?
            settlements << ResellerSettlement.submit(reseller.id, items, reseller.bank_account, show.id)
          end
        rescue Exception => e
          logger.error e.backtrace
        end
      end

      AdminMailer.settlement_summary(shows_to_settle, settlements).deliver
    end
  end
end
