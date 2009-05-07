class Entries < Application
  provides :xml, :js, :yaml, :text
  before :authenticate, :only => [:edit, :update, :destroy]
  # cache_action :index
  cache :index

  def index
    @limit = 20 # FIXME
    @page = (params[:page] || 1).to_i
    @offset = (@page-1)*@limit

    # make plentiful the AR object cache; way faster than joins
    if params[:format] == 'text'
      @entries = Entry.find_all_by_status('confirmed')
    else # limit it...
      # mysql's offset is ridiculously shitty. wonder if it could be replaced w/ inequalities...
      conditions = 'status != "hidden"'
      #@entries = Entry.find(:all, :order => 'created_at DESC', :limit => @limit, :offset => @offset, :conditions => 'status != "hidden"')
      # conditions = "status = 'confirmed' OR status = 'pending'"      
      @entries = Entry.find(:all, :order => 'created_at ASC', :limit => @limit, :offset => @offset, :conditions => conditions, :include => [:flags])
    end
    #Flag.find(:all, :conditions => "entry_id in (#{@entries.map_by_id.join(',')})")
    display @entries
  end
  
  def xml # FIXME should be raw XML, use .rss
    @entries = Entry.find(:all, :order => 'updated_at DESC', :limit => 12)
    display @xml
  end
    
  
  def show
    #coder = HTMLEntities.new
    #id = coder.decode( params[:id] )
    @entry = Entry.find(params[:id])
    display @entry
  rescue ActiveRecord::RecordNotFound
    raise NotFound
  end
  
  def new
    #only_provides :html_escape
    print 'Entry.new... '
    puts params.inspect
    if not params[:url].nil? and not params[:url].empty?
      create      
    else 
      @entry = Entry.new(params[:entry])
      render
    end
  end
  
  def create
    print "Entry.create.... "
    #raise '<img src="http://tramchase.com/images/lolz/lol-not-again-RICKROLL.png" alt="" title="this is what you get" />'

    begin
      url = params[:url] || params[:entry][:url]
      url = "http://#{url}" unless url =~ /^http\:\/\// # prefix w/ http if necessary
      uri = URI.parse(url) # will throw exception if it's got HTML, etc.
      # url.gsub!(/^www\./,'') # not needed by ABP
    rescue
      raise "you submitted a malformed URL: #{url}"
    end
  
    # cleanup YouTube URLs. TODO handle more...
    url = "http://youtube.com/watch?v=#{url.scan(/v=([^&]+)/)[0].to_s}" if url =~ /youtube\.com/

    # checks
    raise "No URL specified!" if uri.to_s.empty?

    # TODO add site blacklisting & IP blacklisting
    raise "Your URL <em>#{url}</em> has been blacklisted. <br /><br /><img src=\"/images/wtf-cat.jpg\" />." if uri.to_s =~ /(rickrolldb\.com|rickblock\.com|nimp\.org|zoy\.org|viagra|cialis|partyhard\.biz|encyclopediadramatica\.com|xeloda|prozac|casino|celexa|gambling|mortgage|xanax|zyban|habbo)/

    # TODO add IP blacklisting
    banned = ['207.190.226.22', '24.63.62.169', '67.181.5.112', 
		# sunday april 20th ish below
		'86.156.61.185', '82.32.90.49', '71.169.42.191', '82.22.69.73', '76.170.93.222', '82.32.90.49', '129.1.206.122',
		# wednesday june 5th 2008 below
		"203.162.2.134", '59.56.159.32', '88.111.32.193', '96.239.137.154', '124.125.85.246', '85.217.43.109', '75.3.243.106', '84.81.126.9'
             ]
    raise '<img src="/images/banhammer.jpg" alt="You have been banned" />.' if banned.include?(request.remote_ip)

    puts "Entry.create: final url = #{url}"
    
    # create if it doesn't exist yet; just confirm if it does
    @entry = Entry.find_by_url(url)
    if @entry.nil?
      ## check if this is actually a website       
      begin
        puts uri.to_s
        req = Net::HTTP.new(uri.host, 80)
        puts req.request_head(uri.path.empty? ? '/' : uri.path)
      rescue
        raise "This does not appear to actually be a website, or else it's down at the moment. <p>#{$! if Merb.environment == 'development'} <p>Please contact us w/ the URL if you think you've received this in error. <br />(email link at the bottom of the page)"
      end
      
      @entry = Entry.new(params[:entry])
      @entry.ip = request.remote_ip
      @entry.url = url if @entry.url != url # checking in case we're not using params[:entry][:url] (e.g. via bookmarklet)
      if @entry.save
        # also give it a confirm by redirecting to confirm URL
      	redirect url(:entry, @entry)
      else
        render "Error creating entry: #{@entry.errors.collect { |e| e.to_s }.join(', ')}"
      end
    else # it already exists, just confirm it
      redirect url(:controller => :entries, :action => :confirm, :id => @entry.id)
    end
    
    ## expire cache
    expire_action(:index)
  rescue
    text = "<h3>Error!</h3> <p>#{$!}</p>"
    if request.xhr? 
      return text
    else
      render text
    end
  end
  
  def edit
    #only_provides :html
    #@entry = Entry.find(params[:id])
    #render
    raise BadRequest
  end
  
  def update
    #@entry = Entry.find(params[:id])
    #if @entry.update_attributes(params[:entry])
    #  redirect url(:entry, @entry)
    #else
      raise BadRequest
    #end
  end
  
  def destroy
    #@entry = Entry.find(params[:id])
    #if @entry.destroy
    #  redirect url(:entries)
    #else
      raise BadRequest
    #end
  end
  
  
  ### flagging ###
  # now require POST operations
  
  def confirm # shortcut to add 'confirm:true' flag
    params[:flag_name] = 'confirm:true'
    flag
  end
  
  def dispute
    params[:flag_name] = 'confirm:false'
    flag
  end
    
  def flag
        
    # build our flag obj
    ip = request.remote_ip
    @entry = Entry.find(params[:id])
    flag = Flag.find_or_initialize_by_entry_id_and_ip(@entry.id, ip)
    raise "already voted!" unless flag.new_record?

    # create -- FIXME
    flag.name = params[:flag_name]
    flag.timestamp = Time.now
    # user id?
    flag.save
    @entry.flags << flag
    @entry.updated_at = Time.now
    @entry.save
      
    # redirect url(:entry, @entry)
    if request.xhr?
      siblings = Flag.find(:all, :conditions => "entry_id = '#{flag.entry_id}' AND name = '#{flag.name}'")
      return siblings.length.to_s+" <script type=\"text/javascript\">$('li#entry-#{flag.entry_id} .thanks em').text('Thanks for your vote').fadeIn('fast');</script>"
    else
      redirect url('/')
    end
  
  rescue
    text = "<h3>Error!</h3> #{$!}"
    if request.xhr?
      return $!.to_s
    else
      render text
    end
  end
  
  
  # get list of flags for a user
  # TODO: should actually be in a FlagsController yo
  def flags_for_ip
    only_provides :js
    flags = Flag.find_all_by_ip(params[:ip]).map(&:entry_id)
    render "var flags = [#{flags.join(',')}];", :layout => false
  end
  
  
end
