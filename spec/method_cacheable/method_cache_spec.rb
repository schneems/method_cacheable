require 'spec_helper'


describe MethodCacheable::MethodCache do
  before(:all) do
    @user = User.new
  end

  before(:each) do
    @uniq ||= 0
    @uniq += 1
  end

  describe 'initialize' do
    it 'saves caller' do
      @user.cache.caller_object.should eq(@user)
    end

    it 'saves cache_method' do
      cache_method = :fetch
      @user.cache(cache_method).cache_operation.should eq(cache_method)
    end

    it 'saves options' do
      options = {:foo => "bar"}
      @user.cache(options).options.should eq(options)
    end

    it 'saves options and cache_method' do
      cache_method = :write
      options = {:foo => "bar"}
      cache = @user.cache(cache_method, options)
      cache.options.should      eq(options)
      cache.cache_operation.should eq(cache_method)
    end
  end
end
