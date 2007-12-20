require File.join(File.dirname(__FILE__),'..','..','spec_helper')

describe "/entries/new" do
  before(:each) do
    @controller,@action = get("/entries/new")
    @body = @controller.body
  end

  it "should mention Entries" do
    @body.should match(/Entries/)
  end
end