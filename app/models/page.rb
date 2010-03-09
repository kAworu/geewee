# static Pages model.
#     body is in markdown (extended)
class Page < ActiveRecord::Base
  # friendly_id, use Page's title.
  has_friendly_id :title, :use_slug => true

  # validations
  validates_uniqueness_of :title
  validates_presence_of   :title, :body
end
