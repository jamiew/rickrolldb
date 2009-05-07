$KCODE = 'UTF8'

#
# gem install -i merb_app_root/gems activesupport-post-2.0.2.gem activerecord-post-2.0.2.gem
#
# Merb.push_path(:lib, Merb.root / "lib") # uses **/*.rb as path glob.

# ==== Dependencies
# dependency "RedCloth", "> 3.0"
# OR
# dependencies "RedCloth" => "> 3.0", "ruby-aes-cext" => "= 1.0"
Merb::BootLoader.after_app_loads do
  # Add dependencies here that must load after the application loads:

  # dependency "magic_admin" # this gem uses the app's model classes
end

# ghetto dependency land -- boy is this app old
#require 'rubygems'
require 'htmlentities'
require 'map_by_method'
require 'net/http'

require 'merb_helpers'
require 'merb-assets'

gem 'benschwarz-merb-cache'
require 'merb-cache'



# RickrollDB is AR+rspec+erb
use_orm :activerecord
use_test :rspec
use_template_engine :erb


# See http://wiki.merbivore.com/pages/merb-core-boot-process
# if you want to know more.
Merb::Config.use do |c|

  # Sets up a custom session id key which is used for the session persistence
  # cookie name.  If not specified, defaults to '_session_id'.
  # c[:session_id_key] = '_session_id'
  
  # The session_secret_key is only required for the cookie session store.
  c[:session_secret_key]  = '21a501824a74375bbe31a179af88a182f9ecf1bc'
  
  # There are various options here, by default Merb comes with 'cookie', 
  # 'memory', 'memcache' or 'container'.  
  # You can of course use your favorite ORM instead: 
  # 'datamapper', 'sequel' or 'activerecord'.
  c[:session_store] = 'cookie'
  
end


# ==== Tune your inflector

# To fine tune your inflector use the word, singular_word and plural_word
# methods of English::Inflect module metaclass.
#
# Here we define erratum/errata exception case:
#
# English::Inflect.word "erratum", "errata"
#
# In case singular and plural forms are the same omit
# second argument on call:
#
# English::Inflect.word 'information'
#
# You can also define general, singularization and pluralization
# rules:
#
# Once the following rule is defined:
# English::Inflect.rule 'y', 'ies'
#
# You can see the following results:
# irb> "fly".plural
# => flies
# irb> "cry".plural
# => cries
#
# Example for singularization rule:
#
# English::Inflect.singular_rule 'o', 'oes'
#
# Works like this:
# irb> "heroes".singular
# => hero
#
# Example of pluralization rule:
# English::Inflect.singular_rule 'fe', 'ves'
#
# And the result is:
# irb> "wife".plural
# => wives
