# Blog Authors.
#
#   they write posts (well, at least they should).
#
class Author < ActiveRecord::Base
  CLIENT_FILE = File.join(Rails.root, 'client', 'geewee.rb')

  # friendly_id, use the Author's name.
  has_friendly_id :name, :use_slug => true

  # relations
  has_many :posts

  # validations
  validates_presence_of   :name, :email
  validates_uniqueness_of :name, :email
  # no need to validate the format of email, authlogic does it for us.

  # authlogic
  acts_as_authentic

  # return the geewee client as a string, configured for the author. Call save!
  # method if needed to ensure sync with the db and the generated client.
  def client!
    save! if changed?
    cfg = {
      'base_url' => GeeweeConfig.entry.bloguri,
      'geewee_api_key' => self.single_access_token
    }
    if self.editor and not self.editor.blank?
      cfg['editor'] = self.editor
    end

    File.read(CLIENT_FILE) + cfg.to_yaml
  end
end
