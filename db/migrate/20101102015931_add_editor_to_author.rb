class AddEditorToAuthor < ActiveRecord::Migration
  def self.up
    add_column :authors, :editor, :string
  end

  def self.down
    remove_column :authors, :editor
  end
end
