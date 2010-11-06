require 'spec_helper'

describe ApplicationController do
  before :each do
    def controller.index
      render :text => 'nice hack'
    end
  end

  context 'when Geewee is not configured' do
    it 'should redirect to the config help' do
      get :index
      response.should redirect_to config_path
    end

    it 'should avoid infinite redirect to the config help' do
      get :controller => :help, :action => :config
      response.should be_success
      response.should_not redirect_to config_path
    end

    it 'should set the :en locale' do
      get :index
      I18n.locale.should == :en
    end
  end

  context 'when Geewee is configured' do
    before :each do
      Factory.create :geewee_config, :locale => 'fr'
      @author = Factory.create :author
    end

    it 'should not redirect to the config help' do
      get :index
      response.should be_success
      response.should_not redirect_to config_path
    end

    describe 'method current_author' do
      it 'should return nil when no geewee_api_key is given' do
        get :index
        controller.send(:current_author).should be_nil
      end
      it 'should return the corresponding author if a valid geewee_api_key is given' do
        get :index, :geewee_api_key => @author.single_access_token
        controller.send(:current_author).should == @author
      end
    end

    describe 'method set_locale' do
      it 'should set the configured locale by default' do
        get :index
        I18n.locale.should == :fr
      end

      it 'should honor params[:locale]' do
        get :index, :locale => 'en'
        I18n.locale.should == :en
      end
    end
  end
end
