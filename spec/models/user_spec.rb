require 'spec_helper'

describe User do
  
  before(:each) do
    @attr = { 
      :name => "Example User", 
      :email => "user@example.it",
      :password => "foobars",
      :password_confirmation => "foobars"
    }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end

  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ''))
    no_name_user.should_not be_valid
  end
  
  it "should require a email" do
    no_email_user = User.new(@attr.merge(:email => ''))
    no_email_user.should_not be_valid
  end
  
  it "should reject names too long" do
    long_name = 'a' * 51
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
  end
  
  it "should accept valid email addresses" do
    addresses = %w[paolo@tax.it TAOLO_TAX@tax.fio.it paolo.tax@gino-serio.com]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end
  
  it "should reject invalid email addresses" do
    addresses = %w[paolo@tax,it TAOLO_TAXtax.fio.it paolo.tax@gino-serio.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end
  
  it "should reject duplicate email addressess" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  it "should reject duplicate email addressess up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  describe "passwords" do
    
    before(:each) do
      @user = User.new(@attr)
    end
    
    it "should have a password attribute" do
      @user.should respond_to(:password)
    end
    
    it "should have password confirmation" do
      @user.should respond_to(:password_confirmation)
    end
  end
  
  describe "password validation" do
    
    it "should require password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).
        should_not be_valid
    end
    
    it "should require a matching password confirmation" do
      User.new(@attr.merge(:password_confirmation => "invalid")).
        should_not be_valid
    end
    
    it "should reject short password" do
      short = "a" * 5
      hash = @attr.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end
    
    it "should reject long password" do
      long = "a" * 41
      hash = @attr.merge(:password => long, :password_confirmation => long)
      User.new(hash).should_not be_valid
    end
  end
  
  describe "password encryption" do 
    
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end
    
    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end
    
    it "should have a salt" do
      @user.should respond_to(:salt)
    end
    
    describe "has_password? method" do
      
      it "should exist" do
        @user.should respond_to(:has_password?)
      end
      
      it "should return true if the passwords matches" do
        @user.has_password?(@attr[:password]).should be_true
      end
      
      it "should return false if the passwords don't match" do
        @user.has_password?("invalid").should be_false
      end
    end
    
    describe "authenticate method" do
      
      it "should exist" do
        User.should respond_to(:authenticate)
      end
      
      it "should return nil on email/password mismatch" do
        User.authenticate(@attr[:email], "wrongpassw").should be_nil
      end
      
      it "should return nil on email address with no user" do
        User.authenticate("bee@foo.com", @attr[:password]).should be_nil
      end
      
      it "should return user on email/password match r" do
        User.authenticate(@attr[:email], @attr[:password]).should == @user
      end
    end
      
  end
  
  describe "admin attributes" do
    
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should respond to admin" do
      @user.should respond_to(:admin)
    end
    
    it "should not be an admin by default" do
      @user.should_not be_admin
    end
    
    it "should be convertible to admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end

  describe "micropost association" do
    
    before(:each) do
      @user = User.create(@attr)
      @mp1 = Factory(:micropost, :user => @user, 
                                 :created_at => 1.day.ago,
                                 :content => "lorem ipsum")
      @mp2 = Factory(:micropost, :user => @user,            
                                 :created_at => 1.hour.ago,
                                 :content => "ipsum loren ginus scapronis")
    end
    
    it "should have a microposts attribute" do
      @user.should respond_to(:microposts)
    end
    
    it "should have the right microposts in the right order" do
      @user.microposts.should == [@mp2, @mp1]
    end
    
    it "should destroy associated microposts" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        #Micropost.find_by_id(micropost.id).should be_nil
        lambda do
          Micropost.find(micropost)
        end.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
    
    describe "status feed" do
      
      it "should have a feed" do
        @user.should respond_to(:feed)
      end
      
      it "should include the user's microposts" do
        @user.feed.should include(@mp1)
        @user.feed.should include(@mp2)
      end
      
      it "should not include a different user's micropost" do
        mp3 = Factory(:micropost, 
                      :user => Factory(:user, :email => Factory.next(:email)))
        @user.feed.should_not include(mp3)
      end
      
    end
  end
  
  describe "relationships" do
        
    before(:each) do
      @user = User.create(@attr)
      @followed = Factory(:user)
    end
    
    it "should have a relationships method" do
      @user.should respond_to(:relationships)
    end
    
    it "should have a following method" do
      @user.should respond_to(:following)
    end
    
    it "should follow another user" do
      @user.follow!(@followed)
      @user.should be_following(@followed)
    end
    
    it "should include the followed user in the following array" do
      @user.follow!(@followed)
      @user.following.should include(@followed)
    end
    
    it "should have an unfollow! method" do
      @user.should respond_to(:unfollow!)
    end
    
    it "should unfollow a user" do
      @user.follow!(@followed)
      @user.unfollow!(@followed)
      @user.should_not be_following(@followed)
    end
    
    it "should have a reverse_relationships method" do
      @user.should respond_to(:reverse_relationships)
    end
    
    it "should have a followers meethod" do
      @user.should respond_to(:followers) 
    end
    
    it "should include the follower in followers" do
      @user.follow!(@followed)
      @followed.followers.should include(@user)
    end
    
    
  end
end
