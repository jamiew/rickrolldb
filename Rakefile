require 'rubygems'
Gem.clear_paths
Gem.path.unshift(File.join(File.dirname(__FILE__), "gems"))

require 'rake'
require 'rake/rdoctask'
require 'rake/testtask'
require 'spec/rake/spectask'
require 'fileutils'
require 'merb-core'
require 'rubigen'
include FileUtils

# Load the basic runtime dependencies; this will include 
# any plugins and therefore plugin rake tasks.
init_env = ENV['MERB_ENV'] || 'rake'
Merb.load_dependencies(:environment => init_env)
     
# Get Merb plugins and dependencies
Merb::Plugins.rakefiles.each { |r| require r } 

desc "start runner environment"
task :merb_env do
  Merb.start_environment(:environment => init_env, :adapter => 'runner')
end

##############################################################################
# ADD YOUR CUSTOM TASKS BELOW
##############################################################################


desc "Clean up rickrolldb entries, e.g. hide heavily disputed entries"
task :entry_cleanup => :merb_env do

  # hide entries w/ enough disputes > confirms
  minimum = 5 #FIXME make dynamic
  entries = Entry.find_all_by_status('pending')
  puts "Found #{entries.length} pending entries..."
  entries.each do |e| 
    if e.flags.length > minimum and e.disputes.length+1 > e.confirmations.length
      puts "Hiding entry #{e.id} => #{e.url}"
      e.status = 'hidden'
      e.save
    elsif e.confirmed?
      puts "Confirming entry #{e.id} => #{e.url}"
      e.status = 'confirmed'
      e.save
    else
      puts "Ignoring #{e.id}: #{e.flags.length} flags, (+)#{e.confirmations.length} (-)#{e.disputes.length}"
    end
  end
end


# requires web2kit: http://www.paulhammond.org/webkit2png/ 
desc "Capture screenshots of all Entries using webkit2png"
task :generate_screenshots => :merb_env do
  width = Entry.thumbnail_width, height = Entry.thumbnail_width
  #unless File.exists?(entry.local_thumbnail_path) 
  clobber = false
  Entry.find(:all).each { |entry| puts `webkit2png "http://#{entry.url}" -o #{entry.id} -C --clipwidth=#{width} --clipheight=#{height} -D "public/screenshots"` unless File.exists?(entry.local_thumbnail_path) and not clobber }
end

task :cache_remote_screenshots => :merb_env do
  clobber = false
  Entry.find(:all).each { |entry| print "#{entry.id}... "; `/usr/local/bin/wget "#{entry.remote_thumbnail}" -O "public/screenshots/#{entry.id}.jpg"` unless File.exists?(entry.local_thumbnail_path) and not clobber; puts "Done!" }
end
