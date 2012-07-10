desc "This task is called by the Heroku cron add-on"
task :cron => :environment do

  #Calculate all org's lifetime value
  if (Time.new.hour == 2)
    Organization.all.each do |o|
      o.delay.calculate_lifetime_value
    end
  end
  
  #Calculate everyone's lifetime value
  if (Time.new.hour == 3)
    Person.all.each do |p|
      p.delay.calculate_lifetime_value
      p.delay.calculate_lifetime_donations
    end
  end

  #Reindex people every night
  if (Time.now.hour == 4)
    Person.delay.reindex
  end
  
  #Settlement, run at 5am
  if Time.now.hour == 5 
    Job::Settlement.run
  end

  #Reseller Settlement, run at 5am on the 3rd of each month.
  # if Time.now.hour == 5 && Time.now.mday == 3
  #   Job::ResellerSettlement.run
  # end

  #AdminStats runs during the day
  if (7..18).include? Time.now.hour
    Job::AdminStats.run
  end

  #Update FAFS projects.  Heroku runs cron hourly so this will run hourly
  Job::FafsDonations.run

end
