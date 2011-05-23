set :stages, %w(demo production)
require 'capistrano/ext/multistage'

set :application, "Artful.ly"
set :repository,  "git@github.com:fracturedatlas/artful.ly.git"

set :use_sudo, false

set :scm, :git
set :deploy_via, :remote_cache

set(:branch, 'master') unless exists?(:branch)
if !branch.nil?
   set :branch, branch
else
   set :branch, "master"
end