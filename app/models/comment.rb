# comments of a Post.
#   name is the comment's author name.
#   email is used for gravatar.
#   body is in markdown format (html disallowed).
class Comment < ActiveRecord::Base
  # relations
  belongs_to :post

  # hook, reset bad URL address.
  # FIXME: better in controller?
  def before_validation
    if self.url == 'http://'
      self.url = nil
    end
  end

  # validations
  validate              :good_email_when_match_blog_author
  validates_presence_of :post, :name, :email, :body
  validates_associated  :post
  validates_format_of   :email, # regexp from http://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html
                        :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  # check that if self.name match an Author, self.email does too.
  def good_email_when_match_blog_author
    if author = Author.find_by_name(self.name) and author.email != self.email
      errors.add(:email, "email doesn't match name")
    end
  end
end
