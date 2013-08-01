require 'spec_helper'

describe EzConfig do
  def ez_config(env)
    EzConfig.new({
      :env  => env,
      :path => File.join(File.dirname(__FILE__), 'config')
    })
  end

  it "should load all configs" do
    config = ez_config(:test)
    config['foo'].should_not be_empty
    config['bar'].should_not be_empty
  end

  it "should load default non_production configurations" do
    config = ez_config(:test)
    config['foo']['foo_path'].should == '/path/to/dev'
  end

  it "should load default production configurations" do
    config = ez_config(:production_japan)
    config['foo']['foo_path'].should == '/path/to/prod'
  end

  it "should load specific configurations" do
    config = ez_config(:production_west_coast)
    config['foo']['foo_path'].should == '/path/to/prod_west'
  end

  it "should have singleton configure options" do
    EzConfig.configure :env => :test, :path => File.join(File.dirname(__FILE__), 'config')
    EzConfig['foo']['foo_path'].should == '/path/to/dev'
  end

  it "should have to_hash" do
    EzConfig.configure :env => :test, :path => File.join(File.dirname(__FILE__), 'config')
    EzConfig.to_hash('foo').is_a?(Hash).should be_true
  end

  it "should tolerate bad configs in the folder" do
    config = ez_config(:test)
    config['foo'].should_not be_empty
  end
  
  it "should raise an error for a config file not found" do
    config = ez_config('test')
    expect { config['foozie'] }.to raise_exception
  end

  it "should raise an error for bad YAML" do
    config = ez_config(:test)
    expect { config['bad'] }.to raise_error(EzConfig::BadConfig)
  end

  it "should raise an error for a missing env" do
    # This is not yet the behavior as it falls back to the default
    # should it do this?
  end
end
