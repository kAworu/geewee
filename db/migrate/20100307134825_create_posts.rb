class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.references :author
      t.references :category

      t.string  :title
      t.text    :intro
      t.text    :body
      t.boolean :published

      t.string :cached_slug
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
