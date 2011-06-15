# Learn more: http://github.com/javan/whenever
set :output, "log/cron.log"

every :weekday, :at => "4:00am" do
  runner "Job::Settlement.run"
end