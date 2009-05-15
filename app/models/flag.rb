class Flag < ActiveRecord::Base
  belongs_to :entry
  belongs_to :user

  def confirmation?
    self.name == 'confirm:true'
  end
  
  def dispute?
    self.name == 'confirm:false'
  end
  
  # after_create :update_entry_counters
  # def update_entry_counters
  #   if self.confirmation?
  #     entry.confirm_count += 1
  #   else
  #     entry.dispute_count += 1
  #   end
  #   entry.save!
  # end
  
end