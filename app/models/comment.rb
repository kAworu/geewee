# comments of a post.
#   email is used for gravatar
#   body is in markdown format.
class Comment < ActiveRecord::Base
  # relations
  belongs_to :post

  # validations
  validates_presence_of :post, :author, :email, :body

  # hook
  def before_create
    if not self.url.blank? and self.url == 'http://'
      self.url = nil
    end
  end
end
