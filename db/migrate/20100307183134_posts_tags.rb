# Join table for has_and_belongs_to_many relation: post <-> tag

class PostsTags < ActiveRecord::Migration
  def self.up
    create_table :posts_tags, :id => false do |t|
      t.references :post
      t.references :tag
    end
  end

  def self.down
    drop_table :posts_tags
  end
end
