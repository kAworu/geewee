# Category of posts
class Category < ActiveRecord::Base
  # relations
  has_many :posts

  # validations
  validates_presence_of   :name, :display_name
  validates_uniqueness_of :name
end
