class Job::Settlement < Job::Base
  class << self
    def run
      range = Settlement.range_for(DateTime.now)
      settle_shows_in(range)
      settle_donations_in(range)
    end

    def settle_shows_in(range)
      logger.info "Settling shows..."
      shows_to_settle = Show.in_range(range[0], range[1]).reject(&:event_deleted?).reject(&:free?)
      settlements = []
      
      shows_to_settle.each do |show|
        logger.info "Settling #{show.event.name}, #{show.datetime_local_to_organization}"

        logger.error "#{show.organization.name} does not have a bank account." if show.organization.bank_account.nil?
        begin
          settlements << Settlement.submit(show.organization.id, show.settleables, show.organization.bank_account, show.id)
        rescue Exception => e
          logger.error e.backtrace
        end
      end
      AdminMailer.settlement_summary(shows_to_settle, settlements).deliver
    end

    def settle_donations_in(range)
      logger.info "Settling donations..."
      Order.in_range(range[0], range[1]).group_by(&:organization_id).each do |organization_id, order_set|
        logger.info "Settling donations for #{Organization.find(organization_id).name}"
        donations = order_set.collect(&:settleable_donations).flatten
        organization = order_set.first.organization

        logger.error "#{organization.id} does not have a bank account." if organization.bank_account.nil?

        if donations.empty?
          logger.error "#{organization.id} has ticket sales but no donations for this range." if organization.bank_account.nil?
        else
          begin
            Settlement.submit(organization.id, donations, organization.bank_account)
          rescue Exception => e
            logger.error e.backtrace
          end
        end
      end
    end
  end
end
