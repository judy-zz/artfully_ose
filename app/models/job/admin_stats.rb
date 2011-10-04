class Job::AdminStats < Job::Base
  class << self
    def run
      AdminStats.load.save
    end
  end
end