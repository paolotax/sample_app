# == Schema Information
# Schema version: 20101222160339
#
# Table name: microposts
#
#  id                                                             :integer         not null, primary key
#  content                                                        :string(255)
#  created_at                                                     :datetime
#  updated_at                                                     :datetime
#  user_id                                                        :integer
#  #<ActiveRecord::ConnectionAdapters::TableDefinition:0x1042904> :integer
#

class Micropost < ActiveRecord::Base
  
  belongs_to :user
  
  attr_accessible :content
  
  default_scope :order => "microposts.created_at DESC"
  
  validates :content,  :presence => true,
                       :length   => { :maximum => 140 }
  
end
