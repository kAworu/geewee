# Tag of a post
class Tag < ActiveRecord::Base
  # relations
  has_and_belongs_to_many :posts

  # validations
  validates_uniqueness_of :name
  validates_presence_of   :name, :display_name
end
