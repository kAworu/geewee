# Tag of a post
class Tag < ActiveRecord::Base
  # friendly_id
  has_friendly_id :name, :use_slug => true

  # relations
  has_and_belongs_to_many :posts

  # validations
  validates_uniqueness_of :name
  validates_presence_of   :name, :display_name
end
