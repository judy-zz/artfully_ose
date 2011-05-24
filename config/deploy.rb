set :stages, %w(demo production)
require 'capistrano/ext/multistage'

set :application, "Artful.ly"
set :repository,  "git@github.com:fracturedatlas/artful.ly.git"

set :use_sudo, false
set :user, "deploy"

set :scm, :git
set :deploy_via, :remote_cache

set(:branch, 'master') unless exists?(:branch)
if !branch.nil?
   set :branch, branch
else
   set :branch, "master"
end
   
#Some wonky sudo workaround
default_run_options[:pty] = true

namespace :athena do
  task :deploy, :roles => :app do
    run_as_user = Capistrano::CLI.ui.ask "Your username: "
    set :user, run_as_user
    athena_version = Capistrano::CLI.ui.ask "Athena version to deploy (X.Y.Z[-SNAPSHOT]): "
    
    sudo "rm -f athena-*tar*"
    sudo "wget -q http://athenadev.fracturedatlas.org:5904/job/ATHENA/lastSuccessfulBuild/artifact/runner/target/athena-#{athena_version}.tar"
    sudo "./deploy.sh #{athena_version}"
  end

  task :stop, :roles => :app do
    run_as_user = Capistrano::CLI.ui.ask "Your username: "
    set :user, run_as_user
    sudo "/opt/athena/bin/athena-stop.sh", :as => "athena"
  end
  
  task :start, :roles => :app do
    run_as_user = Capistrano::CLI.ui.ask "Your username: "
    set :user, run_as_user
    
    #HAck to work around 'sudo cd' not working
    sudo "ls", :as => "athena"
    
    run "cd /opt/athena/bin && sudo -u athena ./athena.sh"
  end
  
  task :taillog, :roles => :app do
    run "tail -f /opt/athena/log/ATHENA-stdout.log"
  end
end