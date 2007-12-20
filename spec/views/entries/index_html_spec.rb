require File.join(File.dirname(__FILE__),'..','..','spec_helper')

describe "/entries" do
  before(:each) do
    @controller,@action = get("/entries")
    @body = @controller.body
  end

  it "should mention Entries" do
    @body.should match(/Entries/)
  end
end