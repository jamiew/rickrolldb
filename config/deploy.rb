set :application, "rickrolldb"
set :repository,  "http://tramchase.com/svn/#{application}"
set :deploy_to, "/www/apps/#{application}"
# set :scm, :subversion

role :app, "col"
role :web, "col"
role :db,  "col", :primary => true


# load production data
desc "Load production data into development database"
task :load_production_data, :roles => :db, :only => { :primary => true } do
  require 'yaml'
  ['config/database.yml'].each do |file|
    database = YAML::load_file(file)

    filename = "dump.#{Time.now.strftime '%Y-%m-%d_%H:%M:%S'}.sql.gz"
    # on_rollback { delete "/tmp/#{filename}" }

    # run "mysqldump -u #{database[:production][:username]} --password=#{database[:production][:password]} #{database[:production][:database]} > /tmp/#{filename}" do |channel, stream, data|
    run "mysqldump -h #{database[:production][:host]} -u #{database[:production][:username]} --password=#{database[:production][:password]} #{database[:production][:database]} | gzip > /tmp/#{filename}" do |channel, stream, data|
      puts data
    end
    get "/tmp/#{filename}", filename
    # exec "/tmp/#{filename}"
    password = database[:development][:password].nil? ? '' : "--password=#{database[:development][:password]}"  # FIXME shows up in process list, do not use in shared hosting
    # FIXME exec and run w/ localhost as host not working :\
    # exec "mysql -u #{database[:development][:username]} #{password} #{database[:development][:database]} < #{filename}; rm -f #{filename}"
    puts "Loading into local db ..."
    `gunzip -c #{filename} | mysql -u #{database[:development][:username]} #{password} #{database[:development][:database]} && rm -f gunzip #{filename}`
  end
  
end

