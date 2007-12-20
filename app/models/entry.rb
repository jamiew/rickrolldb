class Entry < ActiveRecord::Base
  belongs_to :user
  has_many :flags
  has_many :comments
  
  
  def confirmations
    flags.select { |u| u.name == 'confirm:true' }
  end
  
  def disputes
    flags.select { |u| u.name == 'confirm:false' }
  end
end