class Post < ActiveRecord::Base
  belongs_to  :author
  has_and_belongs_to_many :tags

  validates_presence_of :title, :intro, :author_id

  def str_tags
    ts = Array.new
    self.tags.each { |t| ts << t.display_name }
    ts.join(' ')
  end

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
