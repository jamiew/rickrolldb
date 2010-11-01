# rickrolldb.com

#require 'bundler/capistrano'

set :application, 'rickrolldb'
set :deploy_to, "/home/jamie/#{application}"
set :scm,        :git
set :repository, "git@github.com:jamiew/#{application}.git"
set :branch,     "master"

role :app,  "rickrolldb.com", :primary => true
role :web,  "rickrolldb.com", :primary => true
role :db,   "rickrolldb.com", :primary => true

set :migrate_target, :current
set :use_sudo, false
set :ssh_options, {:forward_agent => true}
set :rails_env, 'production'

set(:latest_release)  { fetch(:current_path) }
set(:release_path)    { fetch(:current_path) }
set(:current_release) { fetch(:current_path) }

set(:current_revision)  { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:latest_revision)   { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:previous_revision) { capture("cd #{current_path}; git rev-parse --short HEAD@{1}").strip }

default_environment["RAILS_ENV"] = 'production'
default_run_options[:shell] = 'bash'

namespace :deploy do
  desc "Deploy the MFer"
  task :default do
    update
    restart
  end

  desc "Setup a GitHub-style deployment."
  task :setup, :except => { :no_release => true } do
    dirs = [deploy_to, shared_path]
    dirs += shared_children.map { |d| File.join(shared_path, d) }
    run "#{try_sudo} mkdir -p #{dirs.join(' ')} && #{try_sudo} chmod g+w #{dirs.join(' ')}"
    run "git clone #{repository} #{current_path}"
  end

  task :cold do
    update
    migrate
  end

  task :update do
    transaction do
      update_code
    end
  end

  desc "Update the deployed code."
  task :update_code, :except => { :no_release => true } do
    run "cd #{current_path}; git fetch origin; git reset --hard #{branch}"
    finalize_update
  end

  desc "Update the database (overwritten to avoid symlink)"
  task :migrations do
    transaction do
      update_code
    end
    migrate
    restart
  end

  desc "Restart passenger with restart.txt"
  task :restart, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  namespace :rollback do
    desc "Moves the repo back to the previous version of HEAD"
    task :repo, :except => { :no_release => true } do
      set :branch, "HEAD@{1}"
      deploy.default
    end

    desc "Rewrite reflog so HEAD@{1} will continue to point to at the next previous release."
    task :cleanup, :except => { :no_release => true } do
      run "cd #{current_path}; git reflog delete --rewrite HEAD@{1}; git reflog delete --rewrite HEAD@{1}"
    end

    desc "Rolls back to the previously deployed version."
    task :default do
      rollback.repo
      rollback.cleanup
    end
  end
end

def run_rake(cmd)
  run "cd #{current_path}; #{rake} #{cmd}"
end
