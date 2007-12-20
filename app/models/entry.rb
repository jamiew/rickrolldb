class Entry < ActiveRecord::Base
  belongs_to :user
  has_many :flags
  has_many :comments
  
  validates_uniqueness_of :url, :on => :create, :message => "must be unique"
  
  def confirmations
    flags.select { |u| u.name == 'confirm:true' }
  end
  
  def disputes
    flags.select { |u| u.name == 'confirm:false' }
  end
  
  def blacklist_url
    raw = url.gsub(/^http\:\/\//, '').gsub(/^www\./)
    "*#{raw}*"
  end
  
  def id_for_url
    coder = HTMLEntities.new
    coder.encode( url.gsub('http://', '').gsub('.', 'DOT'), :decimal)
  end
    
    
end