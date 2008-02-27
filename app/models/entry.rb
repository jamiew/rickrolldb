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
    confirmations.length - 2 > disputes.length
  end

  # round for how disputed it is
  def controversy
    disputes.length < confirmations.length ? disputes.length.to_f/confirmations.length.to_f : confirmations.length.to_f / disputes.length.to_f
  rescue ##ZeroDivisionError
    0
  end
  
  def blacklist_url
    raw = url.gsub(/^http\:\/\//, '').gsub(/^www\./, '').gsub(/\/$/, '')
    if url =~ /youtube\.com/
      ytid = url.scan(/v=([^&]+)/)[0].to_s # TESTME
      "youtube.com/get_video?video_id=#{ytid}"
    else # it's a full domain name, let's saw
      "#{raw}#body\n#{raw}#script"
    end
  end
  
  def id_for_url
    coder = HTMLEntities.new
    coder.encode( url.gsub('http://', ''), :decimal)
  end
  alias :stub :id_for_url
  
  def local_thumbnail
    "/screenshots/#{id}-clipped.png"    
  end
  def local_thumbnail_path
    Merb.root+"/public"+local_thumbnail
  end
  
  def thumbnail
    width = 250
    
    #if File.exists?(local_thumbnail_path) #use ours if we've got it
    if false
      local_thumbnail
    else #fallback to thumbnail service
      "http://www.thumbalizr.com/api/?url=http://#{url.gsub(/^http\:\/\//,'')}&width=#{width}"
      # "http://images.websnapr.com/?size=s&url=http://#{url.gsub(/^http\:\/\//,'')}"
      # TODO save from thumbnail service too
    end
  rescue
    "/images/screenshot-default.png"
  end
    
    
end
