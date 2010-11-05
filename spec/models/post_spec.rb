require 'spec_helper'

describe Post do
  describe :validations do
    it { should validate_presence_of :title }
    it { should validate_presence_of :intro }
    it { should validate_presence_of :author }
    it { should validate_presence_of :category }
  end
  describe :associations do
    it { should belong_to(:author) }
    it { should belong_to(:category) }
    it { should have_many(:comments).dependent(:destroy) }
  end

  it 'should define per_page method for will_paginate plugin' do
    Post.should respond_to(:per_page)
  end

  it 'should have a published? method returning true if the post is published' do
    @post = Factory.create :post
    @post.published?.should be_false
    @post.update_attribute(:published_at, Time.now)
    @post.published?.should be_true
  end

  it 'should have a publish! method setting published_at and calling save!' do
    @post = Factory.create :post, :published_at => nil
    @post.should_receive(:save!)
    @post.publish!
    @new_post = Post.find(@post.id)
    @new_post.should be_published
    @new_post.published_at.should be_close Time.now, 1.second
  end

  it 'should set body to nil if blank on save' do
    @post = Factory.create :post, :body => String.new
    @post.body.should be_nil
  end

  context 'when configured' do
    before :each do
      Factory.create :geewee_config
    end

    it "should honor GeeweeConfig's post_count_per_page for pagination" do
      Post.per_page.should == GeeweeConfig.entry.post_count_per_page
    end
  end

  context 'with some entries' do
    before :each do
      @author    = Factory.create :author
      @category  = Factory.create :category
      start_time = Time.now
      6.times do |i|
        p = Factory.build :post, :author => @author, :category => @category
        if i % 2 == 0 then p.publish! else p.save! end
        Timecop.travel 1.hour
      end
      end_time = Time.now
      @middle_time = start_time + (end_time - start_time) / 2
    end

    it 'should order by published_at DESC by default' do
      # remove unpublished entries since it would mess with the order.
      Post.destroy_all(:published_at => nil)
      Post.all.should == Post.find(:all).sort_by(&:published_at).reverse
    end

    it 'should have named scope published returning only published posts' do
      Post.published.should == Post.find(:all, :conditions => ['published_at <> ?', nil])
    end

    it 'should have named scope unpublished returning only unpublished posts' do
      pending 'need published?'
      @posts = Post.unpublished
      Post.all do |post|
        if post.published?
          @posts.should_not include post
        else
          @posts.should include post
        end
      end
    end

    it 'should have named scope published_after returning only posts published after a given date' do
      expected = Post.all.filter { |p| p.published_at > @middle_time }
      Post.published_after(@middle_time).should == expected
    end

    it 'should have named scope published_before returning only posts published before a given date' do
      expected = Post.all.filter { |p| p.published_at < @middle_time }
      Post.published_before(@middle_time).should == expected
    end
  end

  it 'month_of_the_year' do
    pending
  end
end
