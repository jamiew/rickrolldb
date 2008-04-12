desc "Clean up rickrolldb entries, e.g. hide heavily disputed entries"
task :entry_cleanup => :merb_env do

  # hide entries w/ enough disputes > confirms
  minimum = 5 #FIXME make dynamic
  Entry.find_all_by_status('pending').each { |e| if e.flags.length > minimum and e.disputes.length+1 > e.confirmations.length; puts "Hiding entry #{e.id} => #{e.url}"; e.status = 'hidden'; e.save; end}

  # other stuff?
end

