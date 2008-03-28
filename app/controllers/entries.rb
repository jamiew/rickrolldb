class Entries < Application
  provides :xml, :js, :yaml, :text
  before :authenticate, :only => [:edit, :update, :destroy]
  # cache_action :index

  def index
    @limit = 20 # FIXME
    @page = (params[:page] || 1).to_i
    @offset = (@page-1)*@limit
    # approx. 2x faster to add 20 queries for each flag. O_o
    # TODO do a Flag.find(:all) w/ the mapped entry_id's and <=>
    # :include => [:flags], 
    if params[:format] == 'text'
      @entries = Entry.find(:all)
    else # limit it...
      @entries = Entry.find(:all, :order => 'created_at DESC', :limit => @limit, :offset => @offset)
    end
    render @entries
  end
  
  def xml # FIXME should be raw XML, use .rss
    @entries = Entry.find(:all, :order => 'updated_at DESC', :limit => 12)
    render @entries
  end
    
  
  def show
    #coder = HTMLEntities.new
    #id = coder.decode( params[:id] )
    @entry = Entry.find(params[:id])
    render @entry
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
    puts params.inspect
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

    raise "No URL specified!" if uri.to_s.empty?
    raise "The URL you submitted is part of this site, #{site_url}, and for obvious reasons we're not gonna pollute the database with garbage entries. Thanks though." if uri.to_s =~ /rickrolldb.com/ #FIXME use site_url
    puts "Entry.create: final url = #{url}"
    
    # create if it doesn't exist yet; just confirm if it does
    @entry = Entry.find_by_url(url)
    if @entry.nil?
      ## check if this is actually a website       
      begin
        puts uri.inspect
        puts uri.to_s
        req = Net::HTTP.new(uri.host, 80)
        puts req.request_head(uri.path.empty? ? '/' : uri.path)
      rescue
        raise "This does not appear to actually be a website, or else it's down at the moment. <p>#{$! if Merb.environment == 'development'} <p>Please contact us w/ the URL if you think you've received this in error. <br />(email link at the bottom of the page)"
      end
      
      @entry = Entry.new(params[:entry])
      @entry.url = url if @entry.url != url # checking in case we're not using params[:entry][:url] (e.g. via bookmarklet)
      if @entry.save
        # also give it a confirm by redirecting to confirm URL
      	redirect url(:entry, @entry)
      else
        # render :action => :new
        render :inline => "Error creating entry: #{@entry.errors.collect { |e| e.to_s }.join(', ')}"
      end
    else # it already exists, just confirm it
      redirect url(:controller => :entries, :action => :confirm, :id => @entry.id)
    end
    
    ## expire cache
    expire_action(:index)
  rescue
    render :inline => "<h3>Error!</h3> <p>#{$!}</p>"
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

  def confirm # shortcut to add 'confirm:true' flag
    puts params.inspect
    params[:flag_name] = 'confirm:true'
    flag
  end
  def dispute
    params[:flag_name] = 'confirm:false'
    flag
  end
    
  def flag # TODO
    @entry = Entry.find(params[:id])
        
    ip = request.remote_ip
    puts "ip = #{ip}"
    flag = Flag.find_or_initialize_by_entry_id_and_ip(@entry.id, ip)
    puts flag.inspect
    if flag.new_record?
      flag.name = params[:flag_name]
      flag.timestamp = Time.now
      # user id?
      flag.save
      @entry.flags << flag
      @entry.updated_at = Time.now
      @entry.save
    else
      # raise "You've already flagged this entry. Your IP: #{ip}"
      raise "already voted!"
    end
      
    # redirect url(:entry, @entry)
    if request.xhr?
      siblings = Flag.find(:all, :conditions => "entry_id = '#{flag.entry_id}' AND name = '#{flag.name}'")
      render :text => siblings.length.to_s+" <script type=\"text/javascript\">$('li#entry-#{flag.entry_id} .thanks em').text('Thanks for your vote').fadeIn('fast');</script>", :layout => false
    else
      redirect url('/')
    end
  
  rescue
    puts "Problem w/ yr flag sucka: #{$!}"
    render :text => $!.to_s, :layout => :false
  end
  
  
end
