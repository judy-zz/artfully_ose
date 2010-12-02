set :application, "Artful.ly"
set :repository,  "git@github.com:fracturedatlas/artful.ly.git"
set :deploy_to, "/var/www/artful.ly"
set :use_sudo, false

set :scm, :git
set :branch, "master"
set :deploy_via, :remote_cache

set :user, "deploy"

role :web, "184.73.209.105"                          # Your HTTP server, Apache/etc
role :app, "184.73.209.105"                          # This may be the same as your `Web` server
role :db,  "184.73.209.105", :primary => true        # This is where Rails migrations will run

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
    run "#{try_sudo} ln -s #{File.join(deploy_to, 'shared', 'db', 'production.sqlite3')} #{File.join(current_path,'db', 'production.sqlite3')}"
    run "#{try_sudo} cp #{File.join(deploy_to, 'shared', 'config', 'environments', '*')} #{File.join(current_path,'config', 'environments')}"
  end
end
