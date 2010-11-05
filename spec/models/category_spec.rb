require 'spec_helper'

describe Category do
  before :each do
    @category = Factory.create :category
  end

  it { should validate_presence_of   :display_name }
  it { should validate_uniqueness_of :name }
  it { should have_many :posts }

  it 'should not destroy if there is any posts that belongs_to it' do
    @post = Factory.create :post, :category => @category
    @category.destroy.should be_false
  end
end
