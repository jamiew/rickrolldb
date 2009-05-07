class Pages < Application
  cache :about, :contact, :privacy
  
  # stupid stubs
  # TODO should be 
  def about; render; end
  def contact; render; end
  def privacy; render; end
end