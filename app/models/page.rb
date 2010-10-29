# Static Pages.
#
#   * body is in markdown (extended).
#
class Page < ActiveRecord::Base
  # friendly_id, use Page's title.
  has_friendly_id :title, :use_slug => true

  # validations
  validates_uniqueness_of :title
  validates_presence_of   :title, :body

  # return true if self has been modified, false otherwise.
  def modified_since_created?
    self.updated_at.to_i > self.created_at.to_i
  end
end
