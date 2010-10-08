set :application, "Artful.ly"
set :repository,  "git@github.com:fracturedatlas/artful.ly.git"
set :deploy_to, "/var/www/artful.ly"

set :scm, :git
set :scm_passphrase,  Proc.new { Capistrano::CLI.password_prompt('Git Password: ') }
set :branch, "master"
set :deploy_via, :remote_cache

set :user, "deploy"

role :web, "localhost"                          # Your HTTP server, Apache/etc
role :app, "localhost"                          # This may be the same as your `Web` server
role :db,  "localhost", :primary => true        # This is where Rails migrations will run

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
