class Job::FafsDonations < Job::Base
  class << self
    def run
      puts "Update FAFS donations..."
    end
  end
end