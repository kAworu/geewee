class CreateGeeweeConfigs < ActiveRecord::Migration
  def self.up
    create_table :geewee_configs do |t|
      t.string :bloguri
      t.string :blogtitle
      t.string :blogsubtitle
      t.boolean :use_recaptcha, :default => false
      t.string :recaptcha_public_key
      t.string :recaptcha_private_key
      t.integer :post_count_per_page

      t.timestamps
    end
  end

  def self.down
    drop_table :geewee_configs
  end
end
