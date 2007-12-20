require File.join(File.dirname(__FILE__),'..','..','spec_helper')

describe "/pages" do
  before(:each) do
    @controller,@action = get("/pages")
    @body = @controller.body
  end

  it "should mention Pages" do
    @body.should match(/Pages/)
  end
end