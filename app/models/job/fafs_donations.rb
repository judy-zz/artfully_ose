class Job::FafsDonations < Job::Base
  class << self
    def run
      puts "Updating FAFS donations..."
      Organization.linked_to_fa.each do |org|
        puts "Updating organization #{org.id} with FA member id #{org.fa_member_id}"
        org.import_recent_fa_donations
        org.delay.refresh_active_fs_project
      end
    end
  end
end