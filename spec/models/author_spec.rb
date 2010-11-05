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

  # call client! on given author and return the client and the config into two
  # variables.
  def request_client_and_split author
    client, yml = author.client!.split /^__END__$/
  end

  it 'should have the client! method returning the client' do
    client, _ = request_client_and_split @author
    client << "__END__\n"
    client.should == File.read(Author::CLIENT_FILE)
  end

  it 'should have the client! method returning a configured client' do
    _, yml = request_client_and_split @author
    cfg = YAML.load(yml)
    cfg.should be_instance_of Hash
    cfg['base_url'].should == GeeweeConfig.entry.bloguri
    cfg['geewee_api_key'].should == @author.single_access_token
  end

  it 'should save the editor config in the client if any' do
    editor = 'cat'
    @author.editor = editor
    client, yml = request_client_and_split @author
    cfg = YAML.load(yml)
    cfg['editor'].should == editor
  end

  it 'should call save! if client! is called when self has changed' do
    @author.email = 'this_is_my@new.email.com'
    @author.should_receive(:save!)
    lambda do
      @author.client!
    end.should_not raise_error
  end
end
