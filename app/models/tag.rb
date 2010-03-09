# Tag of a post.
#   As for Category, name is display_name.downcase to allow lazy author to mix
#   case.
class Tag < ActiveRecord::Base
  # friendly_id, use Tag's name.
  has_friendly_id :name, :use_slug => true

  # relations
  has_and_belongs_to_many :posts

  # validations
  validates_uniqueness_of :name
  validates_presence_of   :name, :display_name
end
