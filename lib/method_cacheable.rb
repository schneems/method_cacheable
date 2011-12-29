require 'keytar'
require 'active_support/concern'


# include MethodCacheable
#
#
# @example
#   class User < ActiveRecord::Base
#     include MethodCacheable
#
#     def expensive_method(val)
#       sleep 120
#       return val
#     end
#   end
#
#   user = User.last
#
#   user.expensive_method(22)
#   # => 22
#   user.cache.expensive_method(22)
#   # => 22
#
#   Benchmark.measure do
#     user.expensive_method(22)
#   end.real
#   # => 120.00037693977356
#
#   Benchmark.measure do
#     user.cache.expensive_method(22)
#   end.real
#   # => 0.000840902328491211
#
#   # SOOOOOOOO FAST!!
#
# @see MethodCacheable#cache More info on cache options
module MethodCacheable
  mattr_accessor :store
  extend ActiveSupport::Concern


  def self.config
    yield self
  end



  # @overload cache
  # @overload cache(options = {})
  # @overload cache(cache_operation = :fetch)
  # @overload cache(cache_operation = :fetch, options = {})
  #   Creates a MethodCache instance that performs the given cache operation on the method it receives
  #   @param [Symbol] cache_operation (:fetch) The method called on the cache (:write, :read, or :fetch)
  #   @param [Hash] options Optional hash that gets passed to the cache store
  #
  #
  # @example
  #   user = User.last
  #   # cache
  #   user.cache.some_method
  #
  #   # cache(options)
  #   user.cache(:expires_in => 1.minutes).some_method
  #
  #   # cache(cache_operation)
  #   user.cache(:fetch).some_method
  #   user.cache(:read).some_method
  #   user.cache(:write).some_method
  #
  #   # cache(cache_operation, options)
  #   user.cache(:write, :expires_in 2.minutes).some_method
  def cache(*args)
    MethodCache.new(self, *args)
  end


  module ClassMethods
    # @see MethodCacheable#cache
    def cache(*args)
      MethodCache.new(self, *args)
    end
  end

  included do
    include Keytar
  end

  class MethodCache
    attr_accessor :caller, :method, :args, :options, :cache_operation

    def initialize(caller, *method_cache_args)
      self.caller          = caller
      self.cache_operation = method_cache_args.map {|x| x if x.is_a? Symbol }.compact.first||:fetch
      self.options         = method_cache_args.map {|x| x if x.is_a? Hash   }.compact.first
    end

    # Calls the cache based on the given cache_operation
    # @param [Hash] options Options are passed to the cache store
    # @see http://api.rubyonrails.org/classes/ActionController/Caching.html#method-i-cache Rails.cache documentation
    def call
      case cache_operation
      when :fetch
        MethodCacheable.store.fetch(key, options) do
          send_to_caller
        end
      when :read
        read(method, args)
      when :write
        write(method, args) do
          send_to_caller
        end
      end
    end

    def send_to_caller
      caller.send method.to_sym, *args
    end

    def write(method, *args, &block)
      val = block.call
      MethodCacheable.store.write(key, val, options)
    end

    def read(method, *args)
      MethodCacheable.store.read(key, options)
    end

    def for(method , *args)
      self.method = method
      self.args   = args
      self
    end

    # Uses keytar to create a key based on the method and caller if no method_key exits
    # @see http://github.com/schneems/keytar Keytar, it builds keys
    #
    # Method and arguement can optionally be supplied
    #
    # @return the key used to set the cache
    # @example
    #   cache = User.find(263619).cache   # => #<MethodCacheable::MethodCache ... >
    #   cache.method = "foo"              # => "foo"
    #   cache.key                         # => "users:foo:263619"
    def key(tmp_method = nil, *tmp_args)
      tmp_method  ||= method
      tmp_args    ||= args
      key_method = "#{tmp_method}_key".to_sym
      key = caller.send key_method, *tmp_args if caller.respond_to? key_method
      key ||= caller.build_key(:name => tmp_method, :args => tmp_args)
    end

    # Removes the current key from the cache store
    def delete(method, *args)
      self.method = method
      self.args   = args
      MethodCacheable.store.delete(key, options)
    end

    # Checks to see if the key exists in the cache store
    # @return [boolean]
    def exist?(method, *args)
      self.method = method
      self.args   = args
      MethodCacheable.store.exist?(key)
    end
    alias :exists? :exist?

    # Methods caught by method_missing are passed to the caller and used to :write, :read, or :fetch from the cache
    #
    # @see MethodCacheable#cache
    def method_missing(method, *args, &blk)
      self.method = method
      self.args   = args
      if caller.respond_to? method
        call
      else
        send_to_caller
      end
    end
  end
end
