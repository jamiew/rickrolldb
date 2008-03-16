class Entries < Application
  provides :xml, :js, :yaml, :text

  def index
    @limit = 20 # FIXME
    @page = (params[:page] || 1).to_i
    @offset = (@page-1)*@limit
    @all_entries = Entry.find(:all, :include => [:flags, :comments], :order => 'updated_at DESC')
    @entries = @all_entries[@offset...@offset+@limit]
    render @entries
  end
  
  def xml # FIXME should be raw XML, use .rss
    @entries = Entry.find(:all, :include => [:flags, :comments], :order => 'updated_at DESC', :limit => 12)
    render @entries
  end
    
  
  def show
    coder = HTMLEntities.new
    #id = coder.decode( params[:id] )
    id = params[:id]
    @entry = Entry.find_by_url(id, :include => [:flags, :comments])

    # also try w/ http:// prefix (DEPRECATED)
    @entry ||= Entry.find_by_url('http://'+id, :include => [:flags, :comments])
    
    # finally try by ID
    @entry ||= Entry.find(params[:id], :include => [:flags, :comments])
    render @entry
  end
  
  def new
    #only_provides :html_escape
    if not params[:url].empty? # called via bookmarklet
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
    
    # TODO: parse a YouTube URL into something like "youtube:xjf9#fj" 
    #  to ignore "&feature=related", etc. garbage

    raise "No URL specified!" if uri.to_s.empty?
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
        raise "This does not appear to actually be a website, or else it's down at the moment. #{$! if Merb.environment == 'development'}<br />Can you reach it?"
      end
      
      ## we're OK, create the entry
      @entry = Entry.new(params[:entry])
      @entry.url = url if @entry.url != url # checking in case we're not using params[:entry][:url] (e.g. via bookmarklet)
      if @entry.save
        # also give it a confirm by redirecting to confirm URL
      	redirect url(:controller => :entries, :action => :show, :id => @entry.id)
      else
        # render :action => :new
        render :inline => "Error creating entry: #{@entry.errors.collect { |e| e.to_s }.join(', ')}"
      end
    else # it already exists, just confirm it
      redirect url(:controller => :entries, :action => :confirm, :id => @entry.id)
    end
  rescue
    render :inline => "Error: #{$!}"
  end
  
  def edit
    only_provides :html
    @entry = Entry.find(params[:id])
    render
  end
  
  def update
    @entry = Entry.find(params[:id])
    if @entry.update_attributes(params[:entry])
      redirect url(:entry, @entry)
    else
      raise BadRequest
    end
  end
  
  def destroy
    @entry = Entry.find(params[:id])
    if @entry.destroy
      redirect url(:entries)
    else
      raise BadRequest
    end
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
      # user id?
      flag.save
      @entry.flags << flag
      @entry.updated_at = Time.now
      @entry.save
    else
      # raise "You've already flagged this entry. Your IP: #{ip}"
      raise "already voted"
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
