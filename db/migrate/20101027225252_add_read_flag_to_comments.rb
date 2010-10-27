class AddReadFlagToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :read, :boolean, :default => false
    Comment.update_all(:read => true)
  end

  def self.down
    remove_column :comments, :read
  end
end
