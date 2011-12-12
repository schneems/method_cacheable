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
  extend ActiveSupport::Concern
  STORE = nil || Rails.cache


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
    attr_accessor :caller_object, :method, :args, :options, :cache_operation

    def initialize(caller_object, *method_cache_args)
      cache_operation      = method_cache_args.map {|x| x if x.is_a? Symbol }.compact.first
      options           = method_cache_args.map {|x| x if x.is_a? Hash   }.compact.first
      self.cache_operation = cache_operation||:fetch
      self.options      = options
      self.caller_object       = caller_object
    end

    # Uses keytar to create a key based on the method and caller if no method_key exits
    # @see http://github.com/schneems/keytar Keytar, it builds keys
    # @return the key used to set the cache
    # @example
    #   cache = User.find(263619).cache   # => #<MethodCacheable::MethodCache ... >
    #   cache.method = "foo"              # => "foo"
    #   cache.key                         # => "users:foo:263619"
    def key
      key_method = "#{method}_key".to_sym
      key = caller_object.send key_method, *args if caller_object.respond_to? key_method
      key ||= caller_object.build_key(:name => method, :args => args)
    end

    # Calls the cache based on the given cache_operation
    # @param [Hash] options Options are passed to the cache store
    # @see http://api.rubyonrails.org/classes/ActionController/Caching.html#method-i-cache Rails.cache documentation
    def call_cache_operation(options = {})
      if cache_operation == :fetch
        MethodCacheable::STORE.fetch(key, options) do
          caller_object.send method.to_sym, *args
        end
      elsif cache_operation == :read
        MethodCacheable::STORE.read(key, options)
      elsif cache_operation == :write
        val = caller_object.send method.to_sym, *args
        MethodCacheable::STORE.write(key, val, options)
      end
    end

    # Methods caught by method_missing are passed to the caller_object and used to :write, :read, or :fetch from the cache
    #
    # @see MethodCacheable#cache
    def method_missing(method, *args, &blk)
      if caller_object.respond_to? method
        self.method = method
        self.args = args
        call_cache_operation(options)
      else
        super
      end
    end
  end
end
