# Category of posts.
#
#   * name is display_name.downcase, to allow the user to mix the case of
#     Categories. friendly_id use the name attribute.
#
class Category < ActiveRecord::Base
  # friendly_id, use the Category's name.
  has_friendly_id :name, :use_slug => true

  # relations
  has_many :posts

  # set self.name
  def before_validation
    self.name = self.display_name.downcase
  end

  # validations
  validates_presence_of   :name, :display_name
  validates_uniqueness_of :name
end
