desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  
  #Settlement, run at 5am
  if Time.now.hour == 5 
    Job::Settlement.run
  end
  
  #AdminStats runs during the day
  if (7..18).include? Time.now.hour
    Job::AdminStats.run
  end
  
  #Update FAFS projects.  Heroku runs cron hourly so this will run hourly
  Job::FafsDonations.run
  
end