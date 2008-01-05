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
    
  def confirmed?
    confirmations.length > disputes.length
  end

  # score for how disputed it is
  def controversy
    confirmations.length / disputes.length
  rescue ZeroDivisionError
    1
  end
  
  def blacklist_url
    raw = url.gsub(/^http\:\/\//, '').gsub(/^www\./, '').gsub(/\/$/, '')
    if url =~ /youtube\.com/
      ytid = url.scan(/v=([^&]+)/)[0].to_s # TESTME
      "youtube.com/get_video?video_id=#{ytid}"
    else # it's a full domain name, let's saw
      "#{raw}#body
      #{raw}#script"
    end
  end
  
  def id_for_url
    coder = HTMLEntities.new
    coder.encode( url.gsub('http://', '').gsub('.', 'DOT'), :decimal)
  end
  
  def thumbnail
    width = 50
    "http://www.thumbalizr.com/api/?url=http://#{url.gsub(/^http\:\/\//,'')}&width=#{width}"
  rescue
    "/images/screenshot-default.png"
  end
    
    
end
