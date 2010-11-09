require 'spec_helper'

describe HelpController do
  context 'when not configured' do
    %w[index unauthorized config api man development installation].each do |action|
      it "#{action} should not redirect to avoid infinit redirect" do
        get action.to_sym
        response.should_not redirect_to config_path
        response.should be_success
      end
    end
  end
end
