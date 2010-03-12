# Post, a Blog entry.
#
#   * intro and body are in markdown (extended).
#   * published is false by default!
#
class Post < ActiveRecord::Base
  ### scopes
  # we always use the creation order.
  default_scope :order => 'created_at DESC'

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

  # relations
  belongs_to  :author
  belongs_to  :category
  has_many    :comments
  has_and_belongs_to_many :tags

  # validations
  validates_associated  :author, :category, :tags
  validates_presence_of :author, :category
  validates_presence_of :title,  :intro

  # str_tag is a virtual attribute, it represent all the tags associated to self.
  def str_tags
    ts = Array.new
    self.tags.each { |t| ts << t.display_name }
    ts.join(' ')
  end

  # create all tags found in str_tag
  # FIXME: Tags should be saved on Post db creation, not instance creation.
  def str_tags= tags
    unless tags.blank?
      tags.split.each do |tname|
        unless t = Tag.find_by_name(tname.downcase)
           t = Tag.create!(:display_name => tname)
        end
        self.tags << t
      end
    end
  end

  # used for group_by
  def month_and_year
      I18n.localize(self.created_at, :format => :month_and_year)
  end
end
