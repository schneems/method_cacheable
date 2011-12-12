require 'rubygems'


$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../..', 'lib'))

## Fake rails for testing Rails.cache
class Rails
  def self.cache
    self
  end

  def self.fetch(key, options, &block)
    eval("@#{key.gsub(':', '_')} ||= block.call")
  end

  def self.write(key, val, options, &block)
    eval("@#{key.gsub(':', '_')} = val")
  end

  def self.read(key, options)
    eval("@#{key.gsub(':', '_')}")
  end
end


require 'method_cachable'
class User
  include MethodCachable
  define_keys :foo

  def foo(var=nil)
    "bar#{var}"
  end

  def id
   @id ||= rand(100)
  end
end


require 'rspec'
require 'rspec/autorun'

