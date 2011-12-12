require 'spec_helper'


describe MethodCachable do
  before(:each) do
    @user = User.new
    @uniq ||= 0
    @uniq += 1
  end

  describe '' do
    describe 'calling a cached method' do
      describe 'fetch' do
        it 'should return the result of the normal method' do
          @user.cache.foo(@uniq).should == @user.foo(@uniq)
        end

        it 'should bypass the normal method if the cache is written' do
          @user.cache(:write).foo(@uniq)
          @user.should_not_receive(:foo)
          @user.cache(:fetch).foo(@uniq)
        end

        it 'should bypass the normal method if the cache has been fetched before' do
          @user.cache(:fetch).foo(@uniq)
          @user.should_not_receive(:foo)
          @user.cache(:fetch).foo(@uniq)
        end

        it 'should call the normal method if the cache has been not fetched before' do
          @user.should_receive(:foo)
          @user.cache(:fetch).foo(@uniq)
        end

        it 'should call the normal method if the cache has been not fetched before' do
          @user.should_receive(:foo)
          @user.cache.foo(@uniq)
        end

      end

      describe 'read' do
        it 'read should return nil if cache has not been set yet' do
          @user.cache(:read).foo(@uniq).should eq(nil)
        end

        it 'read should return value if cache has been set' do
          result = @user.cache.foo(@uniq)
          @user.cache(:read).foo(@uniq).should eq(result)
        end
      end
    end
  end

end
