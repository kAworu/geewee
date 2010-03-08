class Page < ActiveRecord::Base
  # friendly_id
  has_friendly_id :title, :use_slug => true

  # validations
  validates_presence_of :title, :body
end
