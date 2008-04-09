desc "Clean up rickrolldb entries, e.g. hide heavily disputed entries"
task :entry_cleanup => :merb_env do

  # hide entries w/ enough disputes > confirms
  threshold = 4 #FIXME make dynamic, maybe 10% of total flags?
  Entry.find_all_by_status('pending').each { |e| if e.disputes.length + threshold > e.confirmations.length; puts "Hiding entry #{e.id} => #{e.url}"; e.status = 'hidden'; e.save; end}

  # other stuff?
end

