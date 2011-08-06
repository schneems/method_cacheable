Johnny Cache
------------

I fell into a burning ring of slow methods, but they were cached cached cached, so the they came back super fast...

JohnnyCache is used to wholesale cache a ruby method

    class User < ActiveRecord::Base
      include JohnnyCache

      has_many :friends, pictures

      def foo
        # ... slow query
      end
    end
    user = User.find_by_username("schneems")
    user.friends        # => [<# User ... >, <# User ... >]# normal method
    user.cache.friends  # => [<# User ... >, <# User ... >]# result from cache

you can explicitly write, read methods.

    user.cache(:read).pictures  # => nil
    user.cache(:write).pictures # => [<# Picture ...>, <# Picture ...>] # refreshes the cache
    user.cache(:read).pictures  # => [<# Picture ...>, <# Picture ...>]

by default the `cache` method will will `:fetch` from the cache store. This means that if the key exists it will be pulled, if not the key will be set.

    user.cache(:read).foo   # => nil
    user.cache.foo          # => `# ... slow query` # sets the cache via :fetch
    user.cache.foo          # => `# ... slow query` # pulls from the cache
    
You can also call `:fetch` explicitly if you prefer

    user.cache(:fetch).foo  # => `# ... slow query` # pulls from the cache


Configuration
=============

Any configuration hashes passed to the cache method will be passed to the cache store

      user.cache(:write, :expires_in => 5.seconds).pictures # => [<# Picture ...>, #... ]
      user.cache(:read).pictures                            # => [<# Picture ...>, #... ]
      sleep 10
      user.cache(:read).pictures                            # => nil

# TODO, finish docs
  