class CreateAuthors < ActiveRecord::Migration
  def self.up
    create_table :authors do |t|
      t.string :name
      t.string :email

      t.string :cached_slug
      t.string :salt
      t.string :hashed_password

      t.timestamps
    end
  end

  def self.down
    drop_table :authors
  end
end
