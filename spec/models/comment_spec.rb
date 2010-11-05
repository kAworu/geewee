require 'spec_helper'

describe Comment do
  before :each do
    @comment = Factory.create :comment
  end

  it { should validate_presence_of :post  }
  it { should validate_presence_of :name  }
  it { should validate_presence_of :email }
  it { should validate_presence_of :body  }
  it { should validate_format_of(:email).with(Authlogic::Regex.email)  }
  it { should belong_to :post }

  it 'should reset url if it is "http://" when created' do
    Factory.create(:comment, :url => 'http://').url.should be_nil
  end

  it 'should ensure that email match name if name is a registered author name' do
    expected = I18n.translate('activerecord.errors.email_doesnt_match_name')
    @author  = Factory.create :author

    @comment = Factory.build :comment, :name => @author.name
    @comment.should_not be_valid
    @comment.should have(1).error_on(:email)
    @comment.errors.on(:email).should == expected
  end

  it 'should not allow update' do
      @comment.body = '42'
      @comment.should be_valid
      @comment.save.should be_false
  end

  context 'with some entry in the database' do
    before :each do
      @post = Comment.first.post
      6.times do |i|
        Timecop.travel 1.hour
        Factory.create :comment, :post => @post, :read => (i % 2 == 0)
      end
    end

    it 'should be order by created_at by default' do
      Comment.all.should == Comment.all.sort_by(&:created_at)
    end

    describe 'named scope unread' do
      it 'should return all unreaded comments' do
        Comment.unread.should == Comment.all.delete_if { |c| c.read? }
      end
    end
  end
end
