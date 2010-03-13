# Blog Authors.
#
#   they write posts (well, at least they should).
#
class Author < ActiveRecord::Base
  # friendly_id, use the Author's name.
  has_friendly_id :name, :use_slug => true

  # relations
  has_many :posts

  # validations
  validates_presence_of   :name, :email
  validates_uniqueness_of :name, :email
  # no need to validate the format of email, authlogic does it for us.

  # authlogic
  acts_as_authentic
end
