require 'spec_helper'

describe PostsController do
  before :each do
    Factory.create :geewee_config
  end

  describe 'HTML UI' do
    describe :index do
      context 'with no published posts' do
        it 'should redirect to HelpController' do
          pending 'test ApplicationController first'
          Post.published.count.should be_zero
          get :index
          response.should redirect_to help_path
        end
      end

      context 'with some published posts' do
      end
    end
    describe :show do
    end
  end

  describe 'Atom feed' do
    describe :index do
    end
    describe :show do
    end
  end

  describe 'JSON API' do
    describe :index do
    end
    describe :show do
    end
    describe :create do
    end
    describe :update do
    end
    describe :destroy do
    end
  end
end
