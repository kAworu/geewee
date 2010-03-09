# Blog Authors.
#
#   they write posts (well, at least they should).
#
class Author < ActiveRecord::Base
  # regexp from
  # http://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html
  EmailValidationRegexp = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  # friendly_id, use the Author's name.
  has_friendly_id :name, :use_slug => true

  # relations
  has_many :posts

  # validations
  validates_presence_of   :name, :email
  validates_uniqueness_of :name, :email
  validates_format_of     :email,
                          :with   => EmailValidationRegexp
end
