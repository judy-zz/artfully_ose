set :stages, %w(demo production)
require 'capistrano/ext/multistage'

set :application, "Artful.ly"
set :repository,  "git@github.com:fracturedatlas/artful.ly.git"

set :use_sudo, false

set :scm, :git
#sets branch to the currently checked out git branch
set :branch, $1 if `git branch` =~ /\* (\S+)\s/m
set :deploy_via, :remote_cache
