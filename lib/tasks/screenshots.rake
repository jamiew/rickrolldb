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
  Entry.find(:all).each { |entry| print "#{entry.id}... "; `wget "#{entry.remote_thumbnail}" --quiet -O "public/screenshots/#{entry.id}.jpg"` unless File.exists?(entry.local_thumbnail_path) and not clobber; puts "Done!" }
end