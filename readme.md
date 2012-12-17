Method Cacheable
============

Cache method calls and speed up your Ruby on Rails application with MethodCacheable. It's kindof like [ cache_method](https://github.com/seamusabshere/cache_method?utm_source=rubyweekly&utm_medium=email) but it's more explicit about what's being cached and how.


## Simplicity Rules

This is a very very small library wrapped around `Rails.cache` api. It's goal is to be easy to use, and flexible (can be used without Rails). Currently method_cacheable weights in at about 200 lines with documentation (not counting tests and readme)


In your Model include `MethodCacheable`

app/models/user.rb

```ruby

  class User < ActiveRecord::Base
    include MethodCacheable

    has_many :pictures

    def expensive_method(val)
      sleep 120
      return val
    end
  end

```

Then use the `#cache` method to fetch results from cache when available

```
  user = User.last

  # Call User#expensive_method normally
  Benchmark.measure { user.expensive_method(22) }.real
  # => 120.00037693977356

  # Fetch User#expensive_method from cache
  Benchmark.measure { user.cache.expensive_method(22) }.real
  # => 0.000840902328491211
```


Install
=======
in your Gemfile

    gem 'method_cacheable'


You will also want to have a library for caching objects. Such as `dalli` for using memcache

    gem 'dalli'

Then run

    bundle install


## Set up Memcache

In your `app/config/application.rb` set your Rails cache store to use `dalli`

```ruby
  config.cache_store = :dalli_store
```

In an initializer tell MethodCacheable to use the Rails.cache backend. You can use any object here that responds to `#write`, `#read`, and `#fetch`.

initializers/method_cacheable.rb

```ruby
  MethodCacheable.config do |config|
    config.store = Rails.cache
  end
```

then in your models

    include MethodCacheable

Now you're good to go, just use the `cache` method in that class and you can write, read and fetch any method from cache.


Usage
========

By default the `cache` method will will `:fetch` from the cache store. This means that if the key exists it will be pulled, if not the method will be called, returned, and the key will be set.

``` ruby
  user.cache(:read).expensive_method("w00t") # => nil
  user.cache.expensive_method("w00t")        # => "w00t" # sets the cache via :fetch
  user.cache.expensive_method("w00t")        # => "w00t" # pulls from the cache
```

You can also call `:fetch` explicitly if you prefer

``` ruby
  user.cache(:fetch).expensive_method("w00t")  # => "w00t" # pulls from the cache
```


Explicitly write & read methods.

``` ruby
  user.cache(:read).pictures  # => nil
  user.cache(:write).pictures # => [<# Picture ...>, <# Picture ...>] # refreshes the cache
  user.cache(:read).pictures  # => [<# Picture ...>, <# Picture ...>]
```


Different method arguments to the method generate different cache objects. I.E. different input => different output, same input => same output

``` ruby
  user.cache.expensive_method(:schneems => :is_awesome).inspect
  # => {:schneems => :is_awesome}
  user.cache.expensive_method("j/k lol").inspect
  # => "j/k lol"
```

## Delete An Entry

You can delete any cached method using `cache.delete` and passing in the name of the method and any arguements, for example:

```ruby
user.cache.expensive_method("w00t")           # => "w00t"

user.cache.delete(:expensive_method, "w00t")  # => nil
```


Configuration
=============

Any configuration options passed to the cache method will be passed to the cache store (default is [Rails.cache](http://api.rubyonrails.org/classes/ActionController/Caching.html#method-i-cache Rails.cache))

``` ruby
  user.cache(:write, :expires_in => 5.seconds).pictures # => [<# Picture ...>, #... ]
  user.cache(:read).pictures                            # => [<# Picture ...>, #... ]
  sleep 10                                              # => 2
  user.cache(:read).pictures                            # => nil
```

## Generate Keys

You don't need to generate keys, we do that for you using a library called [keytar](http://github.com/schneems/keytar). If you want to see a key you can call key and pass in the name of the method and any arguments into it.


```ruby
  User.find(9).cache.key(:foo) # => "users:foo:9"
```

Contribution
============

Fork away. If you want to chat about a feature idea, or a question you can find me on the twitters [@schneems](http://twitter.com/schneems).  Put any major changes into feature branches. Make sure all tests stay green, and make sure your changes are covered.


licensed under MIT License
Copyright (c) 2011 Schneems. See LICENSE.txt for
further details.

