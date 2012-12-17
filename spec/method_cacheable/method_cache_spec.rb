require 'spec_helper'


describe MethodCacheable::MethodCache do

  before(:each) do
    @uniq ||= 0
    @uniq += 1
  end

  let(:user) { User.new }

  describe 'write & read' do
    it 'lets us write & read arbitrary items to the cache' do
      symbol           = :arbitrary_entry
      arbitrary_string = "whatever"
      user.cache.write(symbol) {arbitrary_string}
      user.cache.read(symbol).should == arbitrary_string
    end

  end

  describe 'key' do
    it 'returns the key' do
      user.cache.key(:foo).should == "users:foo:#{user.id}"
    end

    it 'returns the key after specifying args and method' do
      cache = user.cache
      cache.method = "foo#{@uniq}"
      cache.args   = [1]
      cache.key.should == "users:foo#{@uniq}:#{user.id}:1"
    end
  end

  describe 'exists?' do
    it 'returns false if the object has not been cached' do
      user.cache.exist?(:new_method).should be_false
    end

    it 'returns true if the object has been cached' do
      user.cache(:write).foo
      user.cache.exist?(:foo).should be_true
    end
  end

  describe 'delete' do
    it 'sends delete to underlying cache object' do
      user.cache.delete(:foo)
      user.cache.exist?(:foo).should be_false
    end
  end


  describe 'initialize' do
    it 'saves caller' do
      user.cache.caller.should == user
    end

    it 'saves cache_method' do
      cache_method = :fetch
      user.cache(cache_method).cache_operation.should == cache_method
    end

    it 'saves options' do
      options = {:foo => "bar"}
      user.cache(options).options.should == options
    end

    it 'saves options and cache_method' do
      cache_method = :write
      options = {:foo => "bar"}
      cache = user.cache(cache_method, options)
      cache.options.should         == options
      cache.cache_operation.should == cache_method
    end
  end
end
