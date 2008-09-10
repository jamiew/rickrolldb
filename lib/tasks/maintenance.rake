
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
      e.save!
    elsif e.confirmed?
      puts "Confirming entry #{e.id} => #{e.url}"
      e.status = 'confirmed'
      e.save!
    else
      puts "Ignoring #{e.id}: #{e.flags.length} flags, (+)#{e.confirmations.length} (-)#{e.disputes.length}"
    end
  end
end

