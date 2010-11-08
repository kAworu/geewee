require 'spec_helper'

describe ArchivesController do
  before :each do
    Factory.create :geewee_config
  end

  describe :by_author do
    it 'should fetch all authors when id is not given' do
      get :by_author
      assigns[:authors].should_not be_nil
      assigns[:authors].should respond_to :each
      assigns[:authors].should == Author.all
    end

    it 'should fetch the wanted author when id is given' do
      author = Factory.create :author
      get :by_author, :id => author
      assigns[:authors].should_not be_nil
      assigns[:authors].should respond_to :each
      assigns[:authors].size.should == 1
      assigns[:authors].first.should == author
    end
  end

  describe :by_category do
    it 'should fetch all categories when id is not given' do
      get :by_category
      assigns[:categories].should_not be_nil
      assigns[:categories].should respond_to :each
      assigns[:categories].should == Category.all
    end

    it 'should fetch the wanted category when id is given' do
      category = Factory.create :category
      get :by_category, :id => category
      assigns[:categories].should_not be_nil
      assigns[:categories].should respond_to :each
      assigns[:categories].size.should == 1
      assigns[:categories].first.should == category
    end
  end

  describe :by_tag do
    it 'should fetch tags of all published posts when id is not given' do
      get :by_tag
      assigns[:tags].should_not be_nil
      assigns[:tags].should respond_to :each
      assigns[:tags].should == Post.published.tag_counts
    end

    it 'should fetch the wanted tag when id is given' do
      @post = Factory.create :post, :tag_list => 'music'
      get :by_tag, :id => 'music'
      assigns[:tags].should_not be_nil
      assigns[:tags].should respond_to :each
      assigns[:tags].size.should == 1
      assigns[:tags] == @post.tags
    end
  end

  describe :by_month do
    it 'should ignore params when month and year are not given' do
      Post.should_receive(:published).and_return(Array.new)
      get :by_month
    end

    it 'should ignore params when year is not given' do
      Post.should_receive(:published).and_return(Array.new)
      get :by_month, :month => 12
    end

    it 'should ignore params when month is not given' do
      Post.should_receive(:published).and_return(Array.new)
      get :by_month, :year => 2010
    end

    it 'should use month and year params' do
      Post.should_receive(:from_month_of_year).with(2010, 12).and_return(Array.new)
      get :by_month, :year => 2010, :month => 12
    end

    it 'should group posts by month of the year' do
      6.times do |i|
        Timecop.travel(Time.now + i.month) do
          Factory.create :post, :published => (i % 3 != 0)
        end
      end
      get :by_month
      assigns[:posts].should == Post.published.group_by(&:month_of_the_year)
    end
  end
end
