# all your other controllers should inherit from this one to share code.
class Application < Merb::Controller
  
  # sitewide config
  def site_url
    "rickrolldb.com"
  end

  # authentication
  def authenticate
    throw :halt, "You don't have permissions to do that!"
  end
  
end 
