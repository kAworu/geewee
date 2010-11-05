# Comments of a Post.
#
#   * name is the comment's author name.
#   * email is used for gravatar.
#   * body is in markdown format (html disallowed).
#
class Comment < ActiveRecord::Base
  # relations
  belongs_to :post

  # we always use the creation order.
  default_scope :order => 'created_at'

  # get only the unread Comments.
  named_scope :unread, {:conditions => ['read = ?', false]}

  # hook, reset bad URL address.
  def before_validation
    if self.url == 'http://'
      self.url = nil
    end
  end

  # validations
  validate              :good_email_when_match_blog_author
  validates_presence_of :post, :name, :email, :body
  validates_associated  :post
  validates_format_of   :email, :with => Authlogic::Regex.email

  # disallow update of comment.
  def before_update
    false
  end

  # check that if self.name match an Author, self.email does too.
  def good_email_when_match_blog_author
    if author = Author.find_by_name(self.name) and author.email != self.email
      errors.add(:email, I18n.translate('activerecord.errors.email_doesnt_match_name'))
    end
  end
end
