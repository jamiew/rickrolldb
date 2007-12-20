require File.join(File.dirname(__FILE__),'..','..','spec_helper')

describe "/pages/edit" do
  before(:each) do
    @controller,@action = get("/pages/edit")
    @body = @controller.body
  end

  it "should mention Pages" do
    @body.should match(/Pages/)
  end
end