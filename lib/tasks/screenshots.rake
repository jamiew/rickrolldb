desc "Capture screenshots of all Entries using webkit2png"
task :capture_screenshots => :merb_env do
  width = 250, height = 250
  Entry.find(:all).each { |entry| print `webkit2png "http://#{entry.url}" -o #{entry.id} -C --clipwidth=#{width} --clipheight=#{height} -D "public/screenshots"` unless File.exists?(entry.local_thumbnail_path) }
end
