# Category of posts
class Category < ActiveRecord::Base
  # friendly_id
  has_friendly_id :name, :use_slug => true

  # relations
  has_many :posts

  # validations
  validates_presence_of   :name, :display_name
  validates_uniqueness_of :name
end
