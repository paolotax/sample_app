require 'spec_helper'

describe MicropostsController do
  
  render_views

  describe "access controll" do
    
    it "should deny access to 'create'" do
      post :create
      response.should redirect_to(signin_path)
    end
    
    it "should deny access to 'destroy'" do
      delete :destroy, :id => 1
      response.should redirect_to(signin_path)
    end
    
  end
  
  describe "POST micropost 'create'" do
    
    before(:each) do
      @user = test_sign_in(Factory(:user))
    end
    
    describe "failure" do
      
      before(:each) do
        @attr = { :content => ""}
      end
      
      it "should not create a micropost" do
        lambda do
          post :create, :micropost => @attr
        end.should_not change(Micropost, :count).by(1)
      end
      
      it "should re-render the home page" do
        post :create, :micropost => @attr
        response.should render_template('pages/home')
      end
    end
    
    describe "success" do
      
      before(:each) do
        @attr = {:content => "lorem ipsum" }
      end
      
      it "should create a micropost" do
        lambda do
          post :create, :micropost => @attr 
        end.should change(Micropost, :count).by(1)
      end
    
      it "should redirect to root path" do
        post :create, :micropost => @attr 
        response.should redirect_to(root_path)
      end
      
      it "should have a flash success" do
        post :create, :micropost => @attr
        flash[:success].should =~  /micropost created/i
      end
      
    end
  end
  
  describe "DELETE microposts 'destroy'" do
    
    describe "for unauthorized user" do
      
      before(:each) do
        @user = Factory(:user)
        wrong_user = Factory(:user, :email => Factory.next(:email))
        @micropost = Factory(:micropost, :user => @user)
        test_sign_in(wrong_user)
      end
      
      it "should deny access" do
        delete :destroy, :id => @micropost
        response.should redirect_to(root_path)
      end
    end
    
    describe "for authorized users" do
      
      before(:each) do
        @user = Factory(:user)
        @micropost = Factory(:micropost, :user => @user)
        test_sign_in(@user)
      end
      
      it "should destroy micropost" do
        lambda do
          delete :destroy, :id => @micropost
          response.should redirect_to(root_path)
        end.should change(Micropost, :count).by(-1)
      end
    end
  end
end