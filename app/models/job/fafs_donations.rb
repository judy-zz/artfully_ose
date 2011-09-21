class Job::FafsDonations < Job::Base
  class << self
    def run
      puts "Updating FAFS donations..."
      Organization.linked_to_fa.each do |org|
        puts "Updating organization #{org.id} with FA member id #{org.fa_member_id}"
        org.delay.refresh_active_fs_project
        org.delay.import_recent_fa_donations
      end
    end
  end
end