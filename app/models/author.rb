require 'digest/sha1'

# Blog Author(s)
#   they write posts.
class Author < ActiveRecord::Base
  # relations
  has_many :posts

  # validations
  validates_presence_of   :name, :email, :hashed_password, :salt
  validates_uniqueness_of :name

  # virtual attribute
  def password= password
    new_salt
    unless password.blank?
      self.hashed_password = Author.encrypted_password(password, self.salt)
    end
  end

  # virtual attribute
  def password
    String.new
  end

  # Author.authenticate take a name and a password and return the Author object
  # if authentication was successfull, nil otherwise.
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

  # create a new salt for password protection.
  def new_salt
    self.salt = object_id.to_s + rand.to_s
  end

  # Author.encrypted_password use SHA1 to hash the given password with the
  # given salt.
  def self.encrypted_password(password, salt)
    salted_pass = 'wibble' + password + salt + '42'
    Digest::SHA1.hexdigest(salted_pass)
  end
end
