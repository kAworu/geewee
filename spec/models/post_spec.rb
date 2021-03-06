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
      @post = Factory.create :post, :published => false
      @post.should_not be_published
      lambda { @post.publish! }.should_not raise_error
      @post.reload
      @post.should be_published
      @post.published_at.should be_close Time.now, 1.second
    end
  end

  describe :published_at_or_now do
    it 'should always return a valid date' do
      @post = Factory.create :post, :published => false
      @post.published_at.should be_nil
      @post.published_at_or_now.should_not be_nil
      @post.published_at_or_now.should be_close Time.now, 1.second
      @post.publish!
      @post.published_at.should_not be_nil
      @post.published_at_or_now.should == @post.published_at
    end
  end

  it 'should set published_at on create if published is true' do
    @post = Factory.create :post, :published => true
    @post.published_at.should_not be_nil
    @post.published_at.should be_close Time.now, 1.second
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
        p = Factory.create :post, :published => (i % 2 == 0)
        Timecop.travel 2.week
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

    describe 'named scope from_month_of_year' do
      it 'should return posts published on the given month' do
        start = Date.new(@middle_time.year, @middle_time.month)
        expected = Post.all.delete_if do |p|
          not p.published? or
            (p.published_at < start or p.published_at > (start + 1.month))
        end.sort_by(&:published_at).reverse
        got = Post.from_month_of_year(@middle_time.year, @middle_time.month)
        got.should == expected
      end
    end
  end

  describe :month_of_the_year do
    it 'should return "month year" for posts' do
      # NOTE: since month_of_the_year use I18n.localize(), we localized Time.
      @post_at_christmas = Factory.create :post,
        :published_at => Time.local(2010, 12, 24, 23, 59, 59)
      @post_at_new_year  = Factory.create :post,
        :published_at => Time.local(2010, 12, 31, 23, 59, 59)
      @post_in_summer    = Factory.create :post,
        :published_at => Time.local(2011, 06, 21, 00, 00, 00)
      # we're testing using group_by(), since it's how we need it in the app.
      I18n.locale = :en
      @result = Post.published.group_by(&:month_of_the_year)
      @result.keys.should == ['June 2011', 'December 2010']
      @result['June 2011'].should_not include @post_at_christmas
      @result['June 2011'].should_not include @post_at_new_year
      @result['June 2011'].should     include @post_in_summer
      @result['December 2010'].should     include @post_at_christmas
      @result['December 2010'].should     include @post_at_new_year
      @result['December 2010'].should_not include @post_in_summer
    end
  end

  describe 'named scope from_month_of_year' do
    it 'should return posts published on the given month' do
      nov_30 = Factory.create :post,
        :published_at => DateTime.new(2010, 11, 30, 23, 59, 59)
      dec_01 = Factory.create :post,
        :published_at => DateTime.new(2010, 12, 01, 00, 00, 00)
      dec_31 = Factory.create :post,
        :published_at => DateTime.new(2010, 12, 31, 23, 59, 59)
      jan_01 = Factory.create :post,
        :published_at => DateTime.new(2011, 01, 01, 00, 00, 00)
      one_year_before = Factory.create :post,
        :published_at => DateTime.new(2009, 12, 24, 00, 00, 00)
      the_good_year   = Factory.create :post,
        :published_at => DateTime.new(2010, 12, 24, 00, 00, 00)
      one_year_after  = Factory.create :post,
        :published_at => DateTime.new(2011, 12, 24, 00, 00, 00)

      result = Post.from_month_of_year(2010, 12)
      result.should_not include nov_30
      result.should include dec_01
      result.should include dec_31
      result.should_not include jan_01
      result.should include the_good_year
      result.should_not include one_year_before
      result.should_not include one_year_after
    end
  end
end
