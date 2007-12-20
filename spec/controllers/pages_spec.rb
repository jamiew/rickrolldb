require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "Pages Controller", "index action" do
  before(:each) do
    @controller = Pages.build(fake_request)
    @controller.dispatch('index')
  end
end