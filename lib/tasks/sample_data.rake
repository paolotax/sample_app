require 'faker'

namespace :db do
  
  desc "Fill database with sample data"
  task :populate => :environment do
  
    Rake::Task["db:reset"].invoke
    
    make_users
    make_microposts
    make_relationships
       
  end
end

def make_users
  admin = User.create!(:name => "paolotax",
                       :email => "paolo.tassinari@gmail.com",
                       :password => "sisboccia",  
                       :password_confirmation => "sisboccia") 
  admin.toggle!(:admin)                          
  
  admin = User.create!(:name => "Paolo Bergami",
                       :email => "paoloberg@gmail.com",
                       :password => "polso14",  
                       :password_confirmation => "polso14") 
  admin.toggle!(:admin)
  
  90.times do |n|
    name = Faker::Name.name
    email = "example-#{n+1}@rails.org"
    password = "password"
    User.create(:name => name,
                :email => email,
                :password => password,
                :password_confirmation => password)
  end
end

def make_microposts
  User.all(:limit => 6).each do |user|
    50.times do
      user.microposts.create!(:content => Faker::Lorem.sentence(5))
    end
  end
end

def make_relationships
  users = User.all
  user = users.first
  following = users[1..50]
  followers = users[3..40]
  following.each { |followed| user.follow!(followed)}
  followers.each { |follower| user.follow!(user)}
  
end

