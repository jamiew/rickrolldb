require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "Entries Controller", "index action" do
  before(:each) do
    @controller = Entries.build(fake_request)
    @controller.dispatch('index')
  end
end