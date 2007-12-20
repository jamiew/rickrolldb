MERB_ENV="test"
$TESTING=true
require File.join(File.dirname(__FILE__), "..", 'config', 'boot')
require File.join(MERB_ROOT, 'config', 'merb_init')

require 'merb/test/helper'
require 'merb/test/rspec'

### METHODS BELOW THIS LINE SHOULD BE EXTRACTED TO MERB ITSELF
