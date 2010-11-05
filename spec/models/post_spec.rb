require 'spec_helper'

describe Post do
  it { should validate_presence_of :title }
  it { should validate_presence_of :intro }
  it { should validate_presence_of :author }
  it { should validate_presence_of :category }

  it { should belong_to(:author) }
  it { should belong_to(:category) }
  it { should have_many(:comments).dependent(:destroy) }

  describe :publish! do
    it 'should set published_at and call save!' do
      @post = Factory.create :post
      @post.should_not be_published
      @post.should_receive(:save!).exactly(1).times.and_return(true)
      @post.publish!
      @post.should be_published
      @post.published_at.should be_close Time.now, 1.second
    end
  end

  describe :published_at_or_now do
    it 'should always return a valid date' do
      @post = Factory.create :post
      @post.published_at.should be_nil
      @post.published_at_or_now.should_not be_nil
      @post.published_at_or_now.should be_close Time.now, 1.second
      @post.publish!
      @post.published_at.should_not be_nil
      @post.published_at_or_now.should == @post.published_at
    end
  end

  it 'should set body to nil when blank on save' do
    @post = Factory.create :post, :body => String.new
    @post.body.should be_nil
  end

  context 'when configured' do
    before :each do
      Factory.create :geewee_config
    end

    describe :per_page do
      it 'should be defined for will_paginate plugin' do
        Post.should respond_to(:per_page)
      end

      it "should use GeeweeConfig's post_count_per_page for pagination" do
        Post.per_page.should == GeeweeConfig.entry.post_count_per_page
      end
    end
  end

  context 'with some entries' do
    before :each do
      @author   = Factory.create :author
      @category = Factory.create :category
      start     = Time.now
      6.times do |i|
        p = Factory.build :post, :author => @author, :category => @category
        if i % 2 == 0 then p.publish! else p.save! end
        Timecop.travel 1.hour
      end
      stop = Time.now
      @middle_time = Time.at((start.to_i + stop.to_i) / 2)
    end

    it 'should order by published_at DESC by default' do
      # remove unpublished entries since it would mess with the order.
      Post.destroy_all(:published_at => nil)
      Post.all.should == Post.all.sort_by(&:published_at).reverse
    end

    describe 'named scope published' do
      it 'should return only published posts' do
        Post.published.should == Post.all.delete_if { |p| not p.published? }
      end
    end

    describe 'named scope unpublished' do
      it 'should return only unpublished posts' do
        @posts = Post.unpublished
        Post.all do |post|
          if post.published?
            @posts.should_not include post
          else
            @posts.should include post
          end
        end
      end
    end

    describe 'named scope published_after' do
      it 'should return posts published after a given date' do
        expected = Post.all.delete_if do |p|
          not p.published? or p.published_at <= @middle_time
        end.sort_by(&:published_at).reverse
        Post.published_after(@middle_time).should == expected
      end
    end

    describe 'named scope published_before' do
      it 'should return posts published before a given date' do
        expected = Post.all.delete_if do |p|
          not p.published? or p.published_at >= @middle_time
        end.sort_by(&:published_at).reverse
        Post.published_before(@middle_time).should == expected
      end
    end
  end

  describe :month_of_the_year do
    it 'should return "month year" for posts' do
      @post_at_santa_claus = Factory.create :post, :published => true,
        :published_at => Time.local(2010, 12, 24, 23, 59, 59)
      @post_at_new_year    = Factory.create :post, :published => true,
        :published_at => Time.local(2010, 12, 31, 23, 59, 59)
      @post_in_summer      = Factory.create :post, :published => true,
        :published_at => Time.local(2011,  6, 21, 00, 00, 00)
      # we're testing using group_by(), since it's how we need it in the app.
      I18n.locale = :en
      @result = Post.published.group_by(&:month_of_the_year)
      @result.keys.should == ['June 2011', 'December 2010']
      @result['June 2011'].should_not include @post_at_santa_claus
      @result['June 2011'].should_not include @post_at_new_year
      @result['June 2011'].should     include @post_in_summer
      @result['December 2010'].should     include @post_at_santa_claus
      @result['December 2010'].should     include @post_at_new_year
      @result['December 2010'].should_not include @post_in_summer
    end
  end
end
