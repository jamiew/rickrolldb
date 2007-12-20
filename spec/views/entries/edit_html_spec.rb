require File.join(File.dirname(__FILE__),'..','..','spec_helper')

describe "/entries/edit" do
  before(:each) do
    @controller,@action = get("/entries/edit")
    @body = @controller.body
  end

  it "should mention Entries" do
    @body.should match(/Entries/)
  end
end