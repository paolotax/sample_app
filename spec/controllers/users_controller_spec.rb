require 'spec_helper'

describe UsersController do
  
  render_views
  
     
  describe "GET 'show'" do
    
    before(:each) do
      @user = Factory(:user)
    end
    
    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end
    
    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end
    
    it "should have the right title" do
      get :show, :id => @user
      response.should have_selector("title", :content => @user.name)
    end
    
    it "should include the user's name" do
      get :show, :id => @user
      response.should have_selector("h1", :content => @user.name)
    end
    
    it "should have a profile image" do
      get :show, :id => @user
      response.should have_selector("h1>img", :class => "gravatar")
    end
    
    it "should have a the right URL" do
      get :show, :id => @user
      response.should have_selector("td>a", :content => user_path(@user),
                                            :href    => user_path(@user))
    end
      
    
  end
  
  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end
    
    it "should have title" do
      get :new
      response.should have_selector("title", :content => "Sign up")
    end
  end
  
  describe "POST 'create'" do
    
    describe "failure" do
      
      before(:each) do
        @attr = { :name => "", :email => "", :password => "", 
                  :password_confirmation => "" }
      end
  
      it "should have title" do
        post :create, :user => @attr
        response.should have_selector("title", :content => "Sign up")
      end
      
      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')   
      end
      
      it "should not create an User" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end
    end
    
    describe "success" do
      
      before(:each) do
        @attr = { :name => "Gino", :email => "gino@example.com", :password => "secret", 
                  :password_confirmation => "secret" }
      end
  
      it "should create an User" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end
      
      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~  /welcome to sample app/i
      end
      
    end
  end
end
