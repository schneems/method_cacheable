The Cache in Black
==================
Cache method calls and speed up your Ruby on Rails application with JohnnyCache.

Johnny Cache
============

I fell into a burning ring of (slow) methods, but they were cached cached cached, so the they came back super fast...

``` ruby
  class User < ActiveRecord::Base
    include JohnnyCache

    has_many :pictures

    def expensive_method(val)
      sleep 120
      return val
    end
  end

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

    gem 'johnny_cache'

then in your models

    include JohnnyCache


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


One Piece at a Time
===================

      ...._........................................._____.............................
      ...| |........ |......   ....   ............./ ___|...........  .. |.......  ...
      ...| |.. _ \.. __ \.. __ \.. __ \.. |.. |....| |...... _` |.. __|. __ \... _ \..
      /\_| |. (   |. |.| |. |.. |. |.. |. |.. |....| |..... (.  |. (.... |.| |.  __/..
      \___/..\___/.._|.|_|._|.._|._|.._|.\__, |.....\____|.\__,_|.\___|._|.|_|.\___|..
      ...................................____/........................................
      :......................................... .?DDNND8888ZN?..                 ....
      ,......................................... $NMMMMNNMMNDMMN8 .                 ..
      ,..................................... ...7DMMMNMMMMMNMMDDN..               ....
      ,.....................................~~~DO887:~~=77OO7$$O. .               ....
      ,.....................................,,.MMDI=:,.,,:~=~:~?D..               ....
      ,.....................................,,NMM8I=~:~=+?????~:$?..             .....
      :.....................................,,NMMO?~~~~:=?++===:=?....          ......
      ,.....................................,,8MMI+++?I7$$777I+=~.....          ......
      ,.....................................,88ZM?IZ8ODNMOODMN887.....    ............
      :.....................................,I7M?7==$DMMNI:NMM8++.....  ..............
      ,.....................................,,$=I??=~78I==:=OZ+:......................
      :.....................................,,,7Z?I777:I~:,=I?I:......................
      :.....................................,,::~77I?=?=IOD$$?I:......................
      :.....................................:,:OMO$7I+I~~$O=$I7: .....................
      ~::::,,,,,,,,,,,,,,,,,,,,,,,,:::,:::::::88N$D8D8$8DM8ZD$~~............... ......
      ~::::::,,,,,,,,,,,,:,,:::,:?,:::,:7ODZNDMMMMMMND?+7O77NMZ~ ...... ....  ........
      ~~:::::::,,,,,,,:::::,:$ZO8DO88NNDONDZNMMMMMMMNNMMMMMMMNN8+?I7$ZZZZOOO88DDNM, ..
      ~~~::::::::::::::,:I8D88DNNDD8NNND8NONMMMMMMMMMMMMMMMMMNDDD88MMMMMMMMMMMMNMN,  .
      ~~~~:::::::::~:?D8O8D8NMMMMNNDNNDNDDDMNMNMMMMMMMMMMMMMMNNDN8ZZO8MNNNNNNNNDDD....
      ==~~~::::::::$DN8NMNDMMMMMMMDDMNDNNNMMMMMMMMMMMMMMMMMMMMNNDD87$88OZDDDDDDDDD,...
      ===~~~~~~:~?8DDDNNNNMMMMMMMMMNDNMMMNMMMMMMMNMMMMMMMMMMMMMNDDDN+=ZMNDDDNND8?~....
      =+=:ZO7$8O8NDDDDNNNMMMMMMMMMMMMNDMMMMNNMMMMMMMMMMMMMMNNNNNNNDDM=ZNDN88OII77$$$$$
      ==MNNNMMNDNNMNDDNNNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNNNNNNDD8DNM=8NDNMNZZZZZZZZZ
      ZMMNDDNNMMMMMM?====~~7MMMMMMMMMMMMMMMMMMMMMMMMMMNNNNMNNNMMMMMMMMO=DMMNN8ZZZOOZZZ
      MDDNNNNMNMMO=+++==~~~~==MMMMMMMMMMMMMMMMMMMMMMMMMMNNNNMMMMNMOMMMM=~MMNNNOOOOOOOO
      DMNNMMDNMM7?+=++++===~=~~ZOMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM?MMMMM~~MMNNOOOOOOOO
      MMMNDDMNMMZ7I?+++=====+==~=MMMMMMMMNMMMMMMMNMMMMMMMMMMMMMMMM8MMMMMM.,MNNDOOO88O8
      8MMNDDNNNMO7I+?+===++=====~=+MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM..NNN888888O
      ZMMZ,.~MMM8I+~::~===+==+=+++=++DMMMMMNMMMMMMMMMMMMMMMMMMMMMMMMMMNMMMZ,=ND888888O
      Z?~:,...MMDZI+~~~:~:::~~=++?+=+++++=+==~~,NMMMMMMMMMMMMMMMMMMMMMNNNNNDI?ND88888O
      I7+~:,..+MD$I?+==~==~~~~~~~~~~~~?+?+======++MMMMMMMMMMMMMMMMMMMMMMMNMMN8DD8888OO
      ?ZI=:,.. ND$I?++~:MM~=+++=+====~~~:::~~==++=NMMMMMMMMMMMMMMMMMMMMNMMMMD8ND888OOO
      :IZ=~:,,..?ZI?++IDZZ=======+++?++==~~=~~~:::7ONMMMMMMMMMMMMMMMMMNMMMMMMN=Z888888
      :7$7:~:,..,......:D~~=,+==++I7I?+++=++++=++=I77NMMMMMMMMMMMMMMMMMNMMNNMMMNI$8888
      :77Z~~+~:,.. . ,::::,7MI?$?OMM7I$?++++=+?++=Z$$78NMMMMMMMMMMMMMMMMMNMMMMNND~D888
      .,:?7?+?=:,:,..,O8O7I7$ZO$IMMMMMII???++++??ZNZZ$$8MMMMMMMMMMMMMMMMMMMMNNNNDMODD8
      ......~??~~~:,..=8NNMMDZMMD8MMDDZI?????++?+MMMMMMNMMMMMMMMMMMMMMMMMMMMMMMNNMNDD8
      ........~++~:=~: IMMMMDDMMNNMMMNO8D8?=++??7MMMMMMMMMMMMMMMMMMMMMMMNNNNNNDNNNMM88
      ..      .,====II:..MM8?MMMMMMMMMDDZZOO$DO7DNMMMMMMMMMMMMMMMDMMMMMMMMMNNNNDNNDMN8
      ..      . .=7~:?8?I,8MIMMMMMMMM8ZZNN8DD7ND8D88O$MMMMMMMMMMMMMMMMMMMMNNNNNNNDNDND
      ..       ..~,+~:+MDI~+$IMMMMMM?MMM$8MD8D$MO8Z8OOON8?8NMMMMMZ8MMMMMMMNNNNNMMNDDDN
      ..         ,::7I77NM8Z7O?ODO+OI+I8MD$NDMDOMDNDNNO8DM87DDIZN7IMMMMMMMMMMNNNNNNNDD
      .          :7$?7OI7OMM8NMMMMM7++?IIII?ZMM8N8OZD8MNZIND8DN8OZDOIDMMMMMNM8=~INNNDD
      .          ,IZO$7DDZZ8MMMMNM=+?I?IIIIIIMMMMMMMMONZD8$NNZ8Z8D8D8O8D8ZZ~:::::::NDD
      ..       . .,=$D8N8MOMMDMZ~=+++???I7IIMMMMMMMMMMMMMNNN8NDD8DDZ8,D7NDO7ND$7I=~:,,
      ..           .,+OO8OOZI+++???+++??I7I8MMMMMMMDMMMMMMMMMMMZNNDODNDNDDD88DDZZDD$?=
      ..           ...=?I?==+++??III?I??IIZMMMMMMMMMMMMMMMMMMMMM$ZDMNN$NNN$ND8I=?~:Z$8




Contribution
============

Fork away. If you want to chat about a feature idea, or a question you can find me on the twitters [@schneems](http://twitter.com/schneems).  Put any major changes into feature branches. Make sure all tests stay green, and make sure your changes are covered.


licensed under MIT License
Copyright (c) 2011 Schneems. See LICENSE.txt for
further details.