class Job::Settlement < Job::Base
  class << self
    def run
      range = Settlement.range_for(DateTime.now)
      settle_shows_in(range)
      settle_donations_in(range)
    end

    def settle_shows_in(range)
      logger.info "Settling shows..."
      Show.in_range(range[0], range[1]).each do |show|
        logger.info "Settling #{show.event.name}, #{show.datetime}"

        logger.error "#{show.organization.name} does not have a bank account." if show.organization.bank_account.nil?
        Settlement.submit(show.organization.id, show.settleables, show.organization.bank_account, show.id)
      end
    end

    def settle_donations_in(range)
      logger.info "Settling donations..."
      Order.in_range(range[0], range[1]).group_by(&:organization_id).each do |organization_id, order_set|
        logger.info "Settling donations for #{Organization.find(organization_id).name}"
        donations = order_set.collect(&:settleable_donations).flatten
        organization = order_set.first.organization

        logger.error "#{organization.name} does not have a bank account." if organization.bank_account.nil?
        Settlement.submit(organization.id, donations, organization.bank_account)
      end
    end
  end
end