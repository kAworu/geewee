require 'spec_helper'

describe PagesController do
  before :each do
    Factory.create :geewee_config
  end

  describe 'HTML UI' do
    describe :index do
      it 'should assign @pages with all pages' do
        3.times { Factory.create :page }
        get :index
        response.should be_success
        assigns[:pages].should == Page.all
      end
    end

    describe :show do
      it 'should assign @page using the id param' do
        @page = Factory.create :page
        get :show, :id => @page
        response.should be_success
        assigns[:page].should == @page
      end
    end
  end

  describe 'JSON API' do
    it 'should test index'   do pending 'JSON API' end
    it 'should test show'    do pending 'JSON API' end
    it 'should test create'  do pending 'JSON API' end
    it 'should test update'  do pending 'JSON API' end
    it 'should test destroy' do pending 'JSON API' end
  end
end
