require 'rubygems' #todo remove

require 'keytar'
require 'active_support/concern'



module JohnnyCache
  extend ActiveSupport::Concern
  STORE = nil || Rails.cache

  def cache(*args)
    Cache.new(self, *args)
  end


  module ClassMethods
    def cache(*args)
      Cache.new(self, *args)
    end
  end

  included do
    include Keytar
  end

  class Cache
    attr_accessor :caller, :method, :args, :options, :cache_method

    def initialize(caller, *args)
      cache_method      = args.map {|x| x if x.is_a? Symbol }.compact.first
      options           = args.map {|x| x if x.is_a? Hash   }.compact.first
      self.cache_method = cache_method||:fetch
      self.options      = options
      self.caller       = caller
    end

    def key
      key_method = "#{method}_key".to_sym
      key = caller.send key_method, *args if caller.respond_to? key_method
      key ||= caller.build_key(:name => method, :args => args)
    end

    def call_cach_method(options = {})
      if cache_method == :fetch
        JohnnyCache::STORE.fetch(key, options) do
          caller.send method.to_sym, *args
        end
      elsif cache_method == :read
        JohnnyCache::STORE.read(key, options)
      elsif cache_method == :write
        val = caller.send method.to_sym, *args
        JohnnyCache::STORE.write(key, val, options)
      end
    end


    def method_missing(method, *args, &blk)
      if caller.respond_to? method
        self.method = method
        self.args = args
        call_cach_method(options)
      else
        super
      end
    end
  end
end