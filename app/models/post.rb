# Post, a Blog entry.
#
#   * intro and body are in markdown (extended).
#   * published is false by default!
#
class Post < ActiveRecord::Base
  ### scopes
  # we always use the published order.
  default_scope :order => 'published_at DESC'

  # get the last x posts.
  named_scope   :last,
                lambda { |x| { :limit => x } }

  # get only the published Posts.
  named_scope   :published,
                lambda { { :conditions => ['published = ?', true] } }

  # get only the non-published Posts.
  named_scope   :unpublished,
                lambda { { :conditions => ['published = ?', false] } }

  # filter only the Posts published after a given date.
  named_scope   :published_after,
                lambda { |date| { :conditions => ['published_at > ?', date] } }

  # filter only the Posts published before a given date.
  named_scope   :published_before,
                lambda { |date| { :conditions => ['published_at < ?', date] } }

  # friendly_id, use the Post's title.
  has_friendly_id :title, :use_slug => true

  # acts_as_taggable_on_steroids plugin.
  acts_as_taggable

  # hooks
  before_save :reset_empty_body, :set_published_at_if_needed

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

  # set published_at when needed.
  def set_published_at_if_needed
    if self.new_record?
      self.published_at = Time.now if self.published?
    else
      if self.published_at.nil? and self.published? and not self.class.find(self.id).published?
        self.published_at = Time.now
      end
    end
  end

  # used for group_by
  def month_of_the_year
      I18n.localize(self.published_at, :format => :month_of_the_year)
  end
end
