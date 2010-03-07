class RemoveTagsFromPosts < ActiveRecord::Migration
  def self.up
    remove_column :posts, :tags
  end

  def self.down
    add_column :posts, :tags, :string
  end
end
