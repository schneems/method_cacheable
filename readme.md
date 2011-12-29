The Cache in Black
==================
Cache method calls and speed up your Ruby on Rails application with MethodCacheable.

Method Cacheable
============

In your Model include `MethodCacheable`

app/models/user.rb
``` ruby
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
  user.expensive_method(22)
  # => 22

  # Fetch User#expensive_method from cache
  user.cache.expensive_method(22)
  # => 22

  # Call User#expensive_method normally
  Benchmark.measure { user.expensive_method(22) }.real
  # => 120.00037693977356

  # Fetch User#expensive_method from cache
  Benchmark.measure { user.cache.expensive_method(22) }.real
  # => 0.000840902328491211

  # SOOOOOOOO FAST!!
```


Install
=======
in your Gemfile

    gem 'method_cacheable'

In an initializer tell MethodCacheable to use the Rails.cache backend. You can use any object here that responds to `#write`, `#read`, and `#fetch`

initializers/method_cacheable.rb
```ruby
  MethodCacheable.config do |config|
    config.store = Rails.cache
  end
```

then in your models

    include MethodCacheable


Usage
========

Explicitly write & read methods.

``` ruby
  user.cache(:read).pictures  # => nil
  user.cache(:write).pictures # => [<# Picture ...>, <# Picture ...>] # refreshes the cache
  user.cache(:read).pictures  # => [<# Picture ...>, <# Picture ...>]
```

By default the `cache` method will will `:fetch` from the cache store. This means that if the key exists it will be pulled, if not the method will be called, returned, and the key will be set.

``` ruby
  user.cache(:read).expensive_method("w00t") # => nil
  user.cache.expensive_method("w00t")        # => "w00t" # sets the cache via :fetch
  user.cache.expensive_method("w00t")        # => "w00t" # pulls from the cache
```

You can also call `:fetch` explicitly if you prefer (but why, thats more typing)

``` ruby
  user.cache(:fetch).expensive_method("w00t")  # => "w00t" # pulls from the cache
```

Different method arguments to the method generate different cache objects. I.E. different input => different output, same input => same output

``` ruby
  user.cache.expensive_method(:schneems => :is_awesome).inspect
  # => {:schneems => :is_awesome}
  user.cache.expensive_method("j/k lol").inspect
  # => "j/k lol"
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


Contribution
============

Fork away. If you want to chat about a feature idea, or a question you can find me on the twitters [@schneems](http://twitter.com/schneems).  Put any major changes into feature branches. Make sure all tests stay green, and make sure your changes are covered.


licensed under MIT License
Copyright (c) 2011 Schneems. See LICENSE.txt for
further details.




