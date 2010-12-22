Factory.define :user do |user|
  user.name                  "Paolo Tax"  
  user.email                 "paolo@example.com"  
  user.password              "secret"             
  user.password_confirmation "secret"
end  

Factory.sequence :email do |n|
  "person-#{n}@example.com"
end  

Factory.define :micropost do |micropost|
  micropost.content     "lorem ipsum"  
  micropost.association :user
end         