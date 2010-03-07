class Comment < ActiveRecord::Base
  belongs_to :post

  validates_presence_of :post, :author, :email, :body
end
