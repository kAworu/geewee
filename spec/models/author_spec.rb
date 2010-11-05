require 'spec_helper'
require 'yaml'

describe Author do
  before :each do
    @author = Factory.create :author
  end

  it { should validate_presence_of   :name  }
  it { should validate_presence_of   :email }
  it { should validate_uniqueness_of :name  }
  it { should validate_uniqueness_of :email }
  it { should have_many :posts }

  it 'should have the CLIENT_FILE existing' do
    File.should exist Author::CLIENT_FILE
  end

  describe :client! do
    # call client! on given author and return the client and the config into two
    # variables.
    def client_and_config_for author
      client, yml = author.client!.split /^__END__$/
      return [client + "__END__\n", YAML.load(yml)]
    end

    it 'should return the client script' do
      client, _ = client_and_config_for(@author)
      client.should == File.read(Author::CLIENT_FILE)
    end

    it 'should return the configuration within the client script' do
      _, cfg = client_and_config_for(@author)
      cfg.should be_instance_of Hash
      cfg['base_url'].should == GeeweeConfig.entry.bloguri
      cfg['geewee_api_key'].should == @author.single_access_token
    end

    it 'should save the editor config in the client if configured' do
      @author.update_attribute(:editor, 'cat')
      _, cfg = client_and_config_for(@author)
      cfg['editor'].should == 'cat'
    end

    it 'should call save! called when self has changed' do
      @author.email = 'this_is_my@new.email.com'
      @author.should_receive(:save!)
      @author.client!
    end
  end
end
