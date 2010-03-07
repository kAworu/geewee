require 'digest/sha1'

class Author < ActiveRecord::Base
  has_many :posts
  validates_presence_of   :name, :email, :hashed_password, :salt
  validates_uniqueness_of :name

  def password= password
    new_salt
    unless password.blank?
      self.hashed_password = Author.encrypted_password(password, self.salt)
    end
  end

  def password
    String.new
  end

  def self.authenticate(name, password)
    author = Author.find_by_name(name)
    if author
      expected_password = Author.encrypted_password(password, author.salt)
      if author.hashed_password != expected_password
        author = nil
      end
    end
    return author
  end

  private

  def new_salt
    self.salt = object_id.to_s + rand.to_s
  end

  def self.encrypted_password(password, salt)
    salted_pass = 'wibble' + password + salt + '42'
    Digest::SHA1.hexdigest(salted_pass)
  end
end
