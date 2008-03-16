class Entry < ActiveRecord::Base
  belongs_to :user
  has_many :flags
  has_many :comments
  
  validates_uniqueness_of :url, :on => :create, :message => "must be unique"
  
  # interesting bits
  def confirmations; flags.select { |u| u.name == 'confirm:true' }; end
  def disputes; flags.select { |u| u.name == 'confirm:false' }; end
  
  # % of votes needed before it is confirmed (rounded down)
  def confirmation_threshold
    0.7
  end
  def confirmed?
    confirmations.length > (flags.length * confirmation_threshold).floor
  end

  # how disputed is this entry?
  def controversy
    disputes.length < confirmations.length ? 
      disputes.length.to_f/flags.length.to_f : confirmations.length.to_f/flags.length.to_f
  rescue ##ZeroDivisionError
    0
  end
  
  # shortcuts to flag creation for this entry
  # TODO: check for a user or something, yeesh
  def confirm; add_flag('confirm:true'); end
  def dispute; add_flag('confirm:false'); end
  def add_flag(name); Flag.new(:entry_id => id, :name => name).save!; end

  
  # rules for AdBlockPlus 0.7.1+
  def blacklist_url
    raw = url.gsub(/^http\:\/\//, '').gsub(/^www\./, '').gsub(/\/$/, '')
    ## do some magic to decide what to block
    ## TODO do cooler stuff w/ myspace, yahoo video, metcafe, etc.
    if url =~ /youtube\.com/
      ytid = url.scan(/v=([^&]+)/)[0].to_s # TESTME
      "youtube.com/get_video?video_id=#{ytid}"
    else # it's a full domain name, let's hack the page up
      "#{raw}#body\n#{raw}$script"
    end
  end
  
  # for a nice clean URL
  def to_param
    coder = HTMLEntities.new
    coder.encode( url.gsub('http://', ''), :decimal)
  end
  alias :slug :to_param
  
  
  # screenshots for this entry
  def thumbnail
    width = 250
  
    # use a local screenshot if we've got it
    #if File.exists?(local_thumbnail_path)
    if false
      local_thumbnail
    else # fallback to a thumbnail service
      "http://www.thumbalizr.com/api/?url=http://#{url.gsub(/^http\:\/\//,'')}&width=#{width}"
      # "http://images.websnapr.com/?size=s&url=http://#{url.gsub(/^http\:\/\//,'')}"
      # TODO save from thumbnail service too!
    end
  rescue
    "/images/screenshot-default.png"
  end
  
  # or stored locally using the rake task, see /lib/tasks/screenshots.rake
  def local_thumbnail
    "/screenshots/#{id}-clipped.png"    
  end
  def local_thumbnail_path
    Merb.root+"/public"+local_thumbnail
  end
  
  
  # demographics
  ## TODO: voter info (anonymized?), 
  ## maybe a finder for user who created, etc.
  
    
end
