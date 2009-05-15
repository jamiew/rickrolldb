class Entry < ActiveRecord::Base
  belongs_to :user
  has_many :flags
  has_many :comments
  
  validates_uniqueness_of :url, :on => :create, :message => "must be unique"
  
  # interesting bits
  def confirmations
    Flag.count(:conditions => "entry_id = #{self.id} AND name = 'confirm:true'")
  end
  
  def disputes
    Flag.count(:conditions => "entry_id = #{self.id} AND name = 'confirm:false'")
  end
  
  # % of votes needed before it is confirmed (rounded down)
  def confirmation_threshold
    0.57
  end
  def minimum_vote_count
    12
  end
  def confirmed?
    flag_count = flags.count
    if flag_count >= minimum_vote_count and status != 'hidden'
      return confirmations > (flag_count * confirmation_threshold).floor
    else
      return false
    end
  end

  # shortcuts to some admin methods
  def hide!
    self.status = 'hidden'
    self.save(false)
  end

  # fuck fairness. add a grip of disputes
  def dispute!; 8.times { self.dispute }; end
  def confirm!; 8.times { self.confirm }; end
 

  # how disputed is this entry?
  def controversy
    if disputes != confirmations
      ratio = disputes.to_f/flags.count.to_f
      ratio = 1.0 if ratio.to_f.nan? or confirmations == 0 # exceptions, not proper
    else
      ratio = 0.5
    end
    ratio
  rescue ZeroDivisionError
    0.0
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
      #"#{raw}$script\n#{raw}$image\n#{raw}$object"
    end
  end
  
  # shortcut for URL + an http:// prefix if necessary
  def link_url
    self.url =~ /^http/ ? self.url : "http://#{self.url}"
  end
  
  # for a nice clean URL
  def to_param
    # TODO: would use the URL but need regex in the routes
    # coder = HTMLEntities.new
    # coder.encode( url.gsub('http://', ''), :decimal)
    id
  end
  alias :slug :to_param
  
  
  # screenshots (thumbnails) for this entry
  def self.thumbnail_width; 190; end
  def self.thumbnail_height; Entry.thumbnail_width; end
  
  def thumbnail
    # use a local screenshot if we've got it
    if File.exists?(local_thumbnail_path)
      local_thumbnail
    else # fallback to a thumbnail service
      remote_thumbnail
    end
  rescue
    puts $!
    "/images/screenshot-default.png"
  end
  
  # or stored locally using the rake task, see /lib/tasks/screenshots.rake
  def local_thumbnail
    ## when using webkit2png
    # "/screenshots/#{id}-clipped.png"
    ## when caching from thumbalizr
    "/screenshots/#{id}.jpg"
  end
  def local_thumbnail_path
    Merb.root+"/public"+local_thumbnail
  end
  
  # from a third-party service
  def remote_thumbnail(width = Entry.thumbnail_width)
    "http://www.thumbalizr.com/api/?url=http://#{url.gsub(/^http\:\/\//,'')}&width=#{width}&api_key=b0afe046a661efc630a5a0dc082b9385"    
    #"http://images.websnapr.com/?size=s&url=http://#{url.gsub(/^http\:\/\//,'')}"
  end
  
  # demographics
  ## TODO: voter info (anonymized?), 
  ## maybe a finder for user who created, etc.
  
    
end
