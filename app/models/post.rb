# Post, a Blog entry.
#
#   * intro and body are in markdown (extended).
#
class Post < ActiveRecord::Base
  ### scopes
  # we always use the published order.
  default_scope :order => 'published_at DESC'

  # get only the published Posts.
  named_scope :published, lambda {
    { :conditions => ['published = ?', true] }
  }

  # get only the non-published Posts.
  named_scope :unpublished, lambda {
    { :conditions => ['published = ?', false] }
  }

  # filter only the Posts published after a given date.
  named_scope :published_after, lambda { |date|
    { :conditions => ['published = ? AND published_at > ?', true, date] }
  }

  # filter only the Posts published before a given date.
  named_scope :published_before, lambda { |date|
    { :conditions => ['published = ? AND published_at < ?', true, date] }
  }

  # friendly_id, use the Post's title.
  has_friendly_id :title, :use_slug => true

  # acts_as_taggable_on_steroids plugin.
  acts_as_taggable

  # will_paginate configuration
  def self.per_page
    GeeweeConfig.entry.post_count_per_page
  end

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

  # set self to published and save.
  def publish!
    self.published    = true
    self.published_at = Time.now
    save!
  end

  # return a valid date (used for preview).
  def published_at_or_now
    self.published_at or Time.now
  end

  # used for group_by
  def month_of_the_year
      I18n.localize(self.published_at, :format => :month_of_the_year)
  end
end
