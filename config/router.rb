# Merb::Router is the request routing mapper for the merb framework.
#
# You can route a specific URL to a controller / action pair:
#
#   r.match("/contact").
#     to(:controller => "info", :action => "contact")
#
# You can define placeholder parts of the url with the :symbol notation. These
# placeholders will be available in the params hash of your controllers. For example:
#
#   r.match("/books/:book_id/:action").
#     to(:controller => "books")
#   
# Or, use placeholders in the "to" results for more complicated routing, e.g.:
#
#   r.match("/admin/:module/:controller/:action/:id").
#     to(:controller => ":module/:controller")
#
# You can also use regular expressions, deferred routes, and many other options.
# See merb/specs/merb/router.rb for a fairly complete usage sample.

Merb.logger.info("Compiling routes...")
Merb::Router.prepare do |r|
  # RESTful routes
  # r.resources :posts

  r.resources :entries, :member => {:confirm => :post, :dispute => :post} do |entries|
  #r.match(/\/entries\/confirm\/(.*)/).to(:controller => 'entries', :action => 'confirm', :id => "[1]")
  #r.resources :entries, :member => {:dispute => :get} do |entries|
    entries.resources :comments
    entries.resources :flags
  end
  r.match('/page/:page').to(:controller => 'entries', :action =>'index')
  
  # specific routes
  # FIXME: merb-cache interfering with .xml/.txt... AGH
  # r.match(/\/(rss|atom|feed)(\.xml)?/).to(:controller => 'entries', :action => 'rss', :format => 'xml')  
  r.match('/feed.xml').to(:controller => 'entries', :action => 'rss', :format => 'xml')    
  r.match('/blacklist.txt').to(:controller => 'entries', :action => 'blacklist', :format => 'text')

  
  # JSON version of all of a user's flags
  r.match('/flags.js').to(:controller => 'entries', :action => 'flags_for_ip', :format => 'js')
  
  
  # r.resources :user do |users|
    # users.resources :entries, :prefix => 'user_'
    # users.resources :comments, :prefix => 'user_'
    # users.resources :flags, :prefix => 'user_'
  # end
  
  # page shortcuts
  r.match('/about').to(:controller => 'pages', :action =>'about')
  r.match('/contact').to(:controller => 'pages', :action =>'contact')
  r.match('/privacy').to(:controller => 'pages', :action =>'privacy')

  # This is the default route for /:controller/:action/:id
  # This is fine for most cases.  If you're heavily using resource-based
  # routes, you may want to comment/remove this line to prevent
  # clients from calling your create or destroy actions with a GET
  r.default_routes
  
  # default
  r.match('/').to(:controller => 'entries', :action =>'index')
end
