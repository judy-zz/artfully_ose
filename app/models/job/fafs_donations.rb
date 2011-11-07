class Job::FafsDonations < Job::Base
  class << self
    def run
      logger.info("Updating FAFS donations...")
      Organization.linked_to_fa.each do |org|
        logger.info("Updating organization #{org.id} with FA member id #{org.fa_member_id}")
        Donation::Importer.import_recent_fa_donations(organization)
        org.delay.refresh_active_fs_project
      end
    end
  end
end