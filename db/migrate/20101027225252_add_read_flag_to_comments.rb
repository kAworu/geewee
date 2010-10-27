class AddReadFlagToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :read, :boolean, :default => false
  end

  def self.down
    remove_column :posts, :read
  end
end
