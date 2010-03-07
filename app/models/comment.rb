# comments of a post.
#   email is used for gravatar
#   body is in markdown format.
class Comment < ActiveRecord::Base
  # relations
  belongs_to :post

  # validations
  validates_presence_of :post, :author, :email, :body
end
