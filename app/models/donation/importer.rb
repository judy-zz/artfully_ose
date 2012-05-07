class Donation::Importer
  class << self
    def import_recent_fa_donations(organization, since=nil)
      if organization.has_fiscally_sponsored_project?
        since ||= (organization.fiscally_sponsored_project.updated_at - 1.day)
        donations = FA::Donation.find_by_member_id(organization.fa_member_id, since)
        process(donations, organization)
      end
    end
    
    def import_all_fa_donations(organization)
      if organization.has_fiscally_sponsored_project?
        donations = FA::Donation.find_by_member_id(organization.fa_member_id, nil)
        process(donations, organization)
      end
    end

    def process(fa_donations, organization)
      ::Rails.logger.debug "Processing: #{fa_donations.size} fafs donations for org #{organization.id}"
      fa_donations.each do |fa_donation|
        ::Rails.logger.debug "Processing: Donation with fa_id #{fa_donation.id} fafs donations for org #{organization.id}"
        donor = create_person(fa_donation.donor, organization)
        ::Rails.logger.debug "Using donor id #{donor.id}"
        create_order(fa_donation, organization, donor)
      end
    end

    private

    #
    # create_person is creating a new person no matter what.  It needs to NOT create this person unless this is a new donation
    # If this is a new record, have this method return the person BUT WITHOUT PERSISTING THE RECORD.  Then, create_order
    # can decide if it needs to be persisted
    #
    # Or, just merge the damned methods together
    # 
    # Also, I don't think fiscally_sponsored_project.refesh is properly setting the updated_at field
    # Thus asking FA for all donations instead of the most recent
    #
    # And this can all be replaced with find_or_initialize_by
    #
    def create_person(donor, organization)
      if donor.has_keys?
        ::Rails.logger.debug "Donor has email, matching to: #{donor.email}"
        conditions = { :email => donor.email, :first_name => donor.first_name, :last_name => donor.last_name, :organization_id => organization.id }
        person = organization.people.find(:first, :conditions => { :email => donor.email }) || organization.people.create(conditions)
      elsif donor.has_information?
        ::Rails.logger.debug "Donor has no email, but person info is present. Creating a new record."
        conditions = { :email => donor.email, :first_name => donor.first_name, :last_name => donor.last_name, :organization_id => organization.id }
        person = organization.people.build(conditions)
      else
        ::Rails.logger.debug "Donor has no information, creating dummy"
        person = organization.dummy
      end
      person
    end

    def create_order(fa_donation, organization, donor)
      order = Order.find_by_fa_id(fa_donation.id) 
      
      if order.nil?
        donor.save if donor.new_record?
        order = FaOrder.new(:organization => organization, :person => donor)
      end

      order.update_attributes({
        :created_at => DateTime.parse(fa_donation.date),
        :price      => (fa_donation.amount.to_f * 100).to_i,
        :fa_id      => fa_donation.id
      })
      order.save

      create_or_update_items(order, fa_donation, organization)
      order
    end

    def create_or_update_items(order, fa_donation, organization)
      if order.items.blank?
        order.items << organization.items.build(item_attributes(fa_donation, organization, order))
      else
        order.items.first.update_attributes(item_attributes(fa_donation, organization, order))
      end
    end

    def item_attributes(fa_donation, organization, order)
      {
        :order_id        => order.id,
        :product_type    => "Donation",
        :state           => "settled",
        :price           => (fa_donation.amount.to_f * 100).to_i,
        :realized_price  => (fa_donation.amount.to_f * 100).to_i,
        :net             => ((fa_donation.amount.to_f * 100) * 0.94).to_i,
        :fs_project_id   => fa_donation.fs_project_id,
        :nongift_amount  => (fa_donation.nongift.to_f * 100).to_i,
        :is_noncash      => fa_donation.is_noncash || false,
        :is_stock        => fa_donation.is_stock || false,
        :reversed_at     => Time.at(fa_donation.reversed_at.to_i),
        :reversed_note   => fa_donation.reversed_note,
        :fs_available_on => fa_donation.fs_available_on,
        :is_anonymous    => fa_donation.is_anonymous || false,
      }
    end
  end
end