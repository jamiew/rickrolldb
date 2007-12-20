class Entries < Application
  provides :xml, :js, :yaml, :txt
  
  def index
    @entries = Entry.find(:all, :include => [:flags, :comments], :order => 'updated_at DESC')
    render @entries
  end
  
  def show
    id = params[:id].gsub('DOT', '.')
    @entry = Entry.find_by_url(id, :include => [:flags, :comments])

    # also try w/ http:// prefix (DEPRECATED)
    @entry ||= Entry.find_by_url('http://'+id, :include => [:flags, :comments])
    
    # finally
    @entry ||= Entry.find(params[:id], :include => [:flags, :comments])
    render @entry
  end
  
  def new
    only_provides :html
    @entry = Entry.new(params[:entry])
    render
  end
  
  def create
    # sanitize
    params[:entry][:url].gsub!('http://', '') rescue nil
    
    # createz
    @entry = Entry.new(params[:entry])
    if @entry.save
      # redirect url(:entry, @entry)
      redirect '/'
    else
      render :action => :new
    end
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
    puts "IN FLAG...."
    puts params.inspect
    @entry = Entry.find(params[:id])
    flag = Flag.new(:name => params[:flag_name])
    puts flag.inspect
    flag.save    
    @entry.flags << flag
    @entry.updated_at = Time.now
    @entry.save

    # redirect url(:entry, @entry)
    if request.xhr?
      render :inline => 'flagged for great justice'
    else
      redirect url('/')
    end
  end
  
  
end
