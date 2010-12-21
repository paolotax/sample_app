require 'spec_helper'

describe UsersController do
  
  render_views
  
  describe "GET 'index'" do
    
    describe "for non signed users" do
      
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed-in users" do

      before(:each) do
        @user = test_sign_in(Factory(:user))
        second = Factory(:user, :email => "another@example.com")
        third  = Factory(:user, :email => "another@example.net")

        @users = [@user, second, third]
      end

      it "should be successful" do
        get :index
        response.should be_success
      end

      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "All users")
      end

      it "should have an element for each user" do
        get :index
        @users.each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end
    end
  end

     
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
      
      it "should re-render the 'new' page" do
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
      
      it "should redirect to the user show page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end
      
      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~  /welcome to sample app/i
      end
      
      it "should sign in the user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end
    end
  end
  
  describe "GET 'edit" do
        
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
  
    it "should be succesfull" do
      get :edit, :id => @user
      response.should be_success 
    end
  
    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector( 'title', :content => "Edit user" ) 
    end
  end

  describe "PUT 'update'" do
      
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    
    describe "failure" do
      
      before(:each) do
        @attr = { :name => "", :email => "", :password => "", 
                  :password_confirmation => "" }
      end
      
      it "should have title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector("title", :content => "Edit user")
      end
      
      it "should re-render the 'edit' page" do
        put :update, :id => @user, :user => @attr  
        response.should render_template('edit')   
      end
    end
  
    describe "success" do
      
      before(:each) do
        @attr = { :name => "Gino", :email => "gino@example.com", :password => "secret", 
                  :password_confirmation => "secret" }
      end
      
      it "should update an User" do
        put :update, :id => @user, :user => @attr
        user = assigns(:user)
        @user.reload
        @user.name.should == user.name
        @user.email.should == user.email
        @user.encrypted_password.should == user.encrypted_password
      end
      
      it "have a flash method" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~  /succesfully updated profile/i
      end
      
    end
  end
 
  describe "authentication of edit/update actions" do
    
    before(:each) do
      @user = Factory(:user)
    end
    
    describe "for non-signed-in users" do
      
      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path) 
        flash[:notice].should =~  /sign in/i
      end
      
      it "should deny access to 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path) 
      end
    end

    describe "for signed-in users" do
    
      before(:each) do
        wrong_user = Factory(:user, :email => "user@value.it")
        test_sign_in(wrong_user)
      end
    
      it "should require matching users for 'edit'" do
         get :edit, :id => @user
         response.should redirect_to(root_path)
      
      end
    
      it "should require matching users for 'update'" do
         put :update, :id => @user, :user => {}
         response.should redirect_to(root_path)
      end
    end
  end
end
