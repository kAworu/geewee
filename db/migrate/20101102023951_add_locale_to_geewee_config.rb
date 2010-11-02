class AddLocaleToGeeweeConfig < ActiveRecord::Migration
  def self.up
    add_column :geewee_configs, :locale, :string
  end

  def self.down
    remove_column :geewee_configs, :locale
  end
end
