# post, the main model of Rgolb.
class Post < ActiveRecord::Base
  # friendly_id
  has_friendly_id :title, :use_slug => true

  default_scope :order => 'created_at DESC'

  # relations
  belongs_to  :author
  belongs_to  :category
  has_many    :comments
  has_and_belongs_to_many :tags

  # validations
  validates_presence_of :author, :category
  validates_presence_of :title,  :intro

  # str_tag is a virtual attribute, it represent all the tags associated to self.
  def str_tags
    ts = Array.new
    self.tags.each { |t| ts << t.display_name }
    ts.join(' ')
  end

  # create all tags found in str_tag
  def str_tags= tags
    unless tags.blank?
      tags.split.each do |tname|
        unless t = Tag.find_by_name(tname.downcase)
           t = Tag.create!(:name => tname.downcase, :display_name => tname)
        end
        self.tags << t
      end
    end
  end
end
