set :deploy_to, "/var/www/artful.ly"
set :user, "deploy"

role :web, "184.73.209.105"                          # Your HTTP server, Apache/etc
role :app, "184.73.209.105"                          # This may be the same as your `Web` server
role :db,  "184.73.209.105", :primary => true        # This is where Rails migrations will run

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} ln -s #{File.join(deploy_to, 'shared', 'config', 'database.yml')} #{File.join(current_path,'config', 'database.yml')}"
    run "#{try_sudo} ln -s #{File.join(deploy_to, 'shared', 'db', 'demo.sqlite3')} #{File.join(current_path,'db', 'demo.sqlite3')}"
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end