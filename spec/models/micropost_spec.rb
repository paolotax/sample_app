require 'spec_helper'

describe Micropost do
  
  before(:each) do
    @user = Factory(:user)
    @attr = { :content => "lorem ipsum" }
  end
  
  it "should create a new instance with valid attributes" do
    @user.microposts.create!(@attr)
  end
  
  it "should require a content" do
    no_content_micropost = @user.microposts.new(@attr.merge(:content => ''))
    no_content_micropost.should_not be_valid
  end
  
  it "should reject content too long" do
    long_content = 'a' * 141
    long_content_micropost = @user.microposts.new(@attr.merge(:content => long_content_micropost))
    long_content_micropost.should_not be_valid
  end
  
  describe "user association" do
    
    before(:each) do
      @micropost = @user.microposts.create(@attr)
    end
        
    it "should have a user attribute" do
      @micropost.should respond_to(:user)
    end
    
    it "should have the right association" do
      @micropost.user_id.should == @user.id
      @micropost.user.should == @user
    end
    
  end



  
end
