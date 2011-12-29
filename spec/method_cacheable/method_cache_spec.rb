require 'spec_helper'


describe MethodCacheable::MethodCache do

  before(:each) do
    @uniq ||= 0
    @uniq += 1
  end

  let(:user) { User.new }

  describe 'key' do
    it 'returns the key' do
      user.cache.key(:foo).should == "users:foo:#{user.id}"
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
      user.cache.caller_object.should eq(user)
    end

    it 'saves cache_method' do
      cache_method = :fetch
      user.cache(cache_method).cache_operation.should eq(cache_method)
    end

    it 'saves options' do
      options = {:foo => "bar"}
      user.cache(options).options.should eq(options)
    end

    it 'saves options and cache_method' do
      cache_method = :write
      options = {:foo => "bar"}
      cache = user.cache(cache_method, options)
      cache.options.should      eq(options)
      cache.cache_operation.should eq(cache_method)
    end
  end
end
