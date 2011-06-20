class Job::Base
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end