desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  
  #Settlement, run at 5am
  if Time.now.hour == 5 
    Job::Settlement.run
    Job::ResellerSettlement.run
  end
  
  #Reindex people every night
  if (Time.now.hour == 4)
    Person.delay.reindex
  end
  
  #AdminStats runs during the day
  if (7..18).include? Time.now.hour
    Job::AdminStats.run
  end
  
  #Update FAFS projects.  Heroku runs cron hourly so this will run hourly
  
  #Temp fix to not update FAFS
  Job::FafsDonations.run
  
end
