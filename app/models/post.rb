# Post, a Blog entry.
#
#   * intro and body are in markdown (extended).
#
class Post < ActiveRecord::Base
  ### scopes
  # we always use the published order.
  default_scope :order => 'published_at DESC'

  named_scope :published,   { :conditions => ['published = ?', true] }
  named_scope :unpublished, { :conditions => ['published = ?', false] }

  # since we're intersted into the published_at date, it implies published=true
  named_scope :from_month_of_year, lambda { |year, month|
    date = Date.new(year, month)
    { :conditions => ['published = ? AND published_at >= ? AND published_at < ?',
      true, date, (date + 1.month)] }
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
  before_save :reset_empty_body, :set_published_at_if_published

  # relations
  belongs_to  :author
  belongs_to  :category
  has_many    :comments, :dependent => :destroy

  # validations
  validates_associated  :author, :category
  validates_presence_of :author, :category
  validates_presence_of :title,  :intro

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

  # used for group_by, do *not* try on unpublished post, since published_at
  # will be nil.
  def month_of_the_year
      I18n.localize(self.published_at, :format => :month_of_the_year)
  end

  private

  # before save hooks.

  def reset_empty_body
    if self.body and self.body.blank?
      self.body = nil
    end
  end

  def set_published_at_if_published
    if self.published? and self.published_at.nil?
      self.published_at = Time.now
    end
  end
end
