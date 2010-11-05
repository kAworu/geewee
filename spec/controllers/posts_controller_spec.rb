require 'spec_helper'

describe PostsController do
  before :each do
    Factory.create :geewee_config
  end

  context 'with no published posts' do
    it 'should have index method redirect to HelpController' do
      Post.published.count.should be_zero
      get :index
      response.should redirect_to help_path
    end
  end

  context 'with some published posts' do
    before :each do
      (Post.per_page + 1).times do
        Factory.create :post, :published => true
      end
    end

    it 'should have index method displaying the firsts posts' do
      get :index
      assigns[:posts].should_not be_nil
      assigns[:posts].size.should == Post.per_page
    end

    it 'should have show method setting @post and @comment' do
      @post = Post.first
      get :show, :id => @post
      assigns[:post].should == @post
      assigns[:comment].should_not be_nil
      assigns[:comment].should be_new_record
    end

    describe 'Atom feed' do
      it 'should have index method fetching the last 6 published posts' do
        get :index, :format => 'atom'
        assigns[:posts].should == Post.published.first(6)
      end
      it 'should have show method fetching the requested posts' do
        @post = Factory.create :post
        get :show, :format => 'atom', :id => @post
        assigns[:post].should == @post
      end
    end

    describe 'JSON API' do
      it 'should test index'   do pending 'JSON API' end
      it 'should test show'    do pending 'JSON API' end
      it 'should test create'  do pending 'JSON API' end
      it 'should test update'  do pending 'JSON API' end
      it 'should test destroy' do pending 'JSON API' end
      it 'should test publish' do pending 'JSON API' end
    end
  end
end
