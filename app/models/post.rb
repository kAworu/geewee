# Post, a Blog entry.
#
#   * intro and body are in markdown (extended).
#   * published is false by default!
#
class Post < ActiveRecord::Base
  ### scopes
  # we always use the creation order.
  default_scope :order => 'created_at DESC'

  # get the last x posts.
  named_scope   :last,
                lambda { |x| { :limit => x } }

  # get only the published Posts.
  named_scope   :published,
                lambda { { :conditions => ['published = ?', true] } }

  # get only the non-published Posts.
  named_scope   :unpublished,
                lambda { { :conditions => ['published = ?', false] } }

  # filter only the Posts created after a given date.
  named_scope   :created_after,
                lambda { |date| { :conditions => ['created_at > ?', date] } }

  # filter only the Posts created before a given date.
  named_scope   :created_before,
                lambda { |date| { :conditions => ['created_at < ?', date] } }

  # friendly_id, use the Post's title.
  has_friendly_id :title, :use_slug => true

  # acts_as_taggable_on_steroids plugin.
  acts_as_taggable

  # hooks
  before_save :reset_empty_body

  # relations
  belongs_to  :author
  belongs_to  :category
  has_many    :comments, :dependent => :destroy

  # validations
  validates_associated  :author, :category
  validates_presence_of :author, :category
  validates_presence_of :title,  :intro

  # before save hook.
  def reset_empty_body
    if self.body and self.body.blank?
      self.body = nil
    end
  end

  # used for group_by
  def month_of_the_year
      I18n.localize(self.created_at, :format => :month_of_the_year)
  end
end
