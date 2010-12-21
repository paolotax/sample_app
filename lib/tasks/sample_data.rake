require 'faker'

namespace :db do
  
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task["db:reset"].invoke
    User.create!(:name => "Example user",
                 :email => "paolo.tassinari@gto.it",
                 :password => "value01",  
                 :password_confirmation => "value01") 
    99.times do |n|
      name = Faker::Name.name
      email = "example-#{n+1}@rails.org"
      password = "password"
      User.create(:name => name,
                  :email => email,
                  :password => password,
                  :password_confirmation => password)
     end
 
  end
end