class CreateAuthors < ActiveRecord::Migration
  def self.up
    create_table :authors do |t|
      t.string :name
      t.string :email

      # authlogic stuff
      t.string :persistence_token,    :null => false  # required
      t.string :single_access_token,  :null => false  # optional, see Authlogic::Session::Params

      t.string :cached_slug
      t.timestamps
    end
  end

  def self.down
    drop_table :authors
  end
end
