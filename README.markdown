iterable 
========
[![Build Status](https://travis-ci.org/scooter-dangle/iterable.png)](https://travis-ci.org/scooter-dangle/iterable)

A gem providing arrays with [Wikipedia-defined iteration](http://en.wikipedia.org/wiki/Iterator#Contrasting_with_indexing) (as opposed to Wikipedia-defined indexing) via the IterableArray class, where many operations on an array have a defined behavior _while_ the array is being traversed by an iterator method.

In Action (with pretty, moving colors!)
---------------------------------------

If it's running (and it usually is), you can see a live demo (with code at [scooter-dangle/bmore-iterable-talk](http://github.com/scooter-dangle/bmore-iterable-talk)) over at [Tr.yToFoc.us](http://tr.ytofoc.us) if your browser is sufficiently with the times. The example being illustrated is something like this:
````ruby
iter = IterableArray.new [*'a' .. 'l']

iter.cycle do |x|
  iter.swap! x, (iter.shuffle - [x]).first
  sleep 1
end
````
If you follow closely, you'll notice that even when the currently yielded `x` is swapped to another location in the array, the `cycle` block picks up immediately after that new location rather than continuing from `x`'s previous spot. (The `sleep 1` is in there to keep the server from flooding your browser with messages about the status of `iter`, which just goes to show how considerate servers can be.)

Current status (as of 2013 07 21)
---------------------------------

This gem is still under development&mdash;since it receives absolutely no use, I could certainly make massive, disruptive changes to it just on the principle of the matter. That is, however, unlikely, and use that is confined to calling common Array/Enumerable methods on an IterableArray should be safe for a long time. To see what it does, look at the specs&mdash;especially those for complex and nested iteration. All of the specs currently pass except for a pending spec that gets into advanced Array indexing. There are specs for most of the methods implemented.

Targets
-------

Originally built for 1.9.3, the specs currently pass for 1.8.7 and for JRuby and Rubinius in both their respective 1.8 and 1.9 modes. That's far less painful for me to say than it was to achieve.

Motivation
----------

Testing Rubinius by running on it some Ruby tutorials I've followed, I found that my answer to the extra credit [koan](http://rubykoans.com) wasn't terminating because `cycle` kept iterating through an empty player array. I hadn't realized that iterator behavior isn't always defined when you modify the array during iteration, and I wanted to see how far I could get in allowing that behavior to be defined.

Usage notes
-----------

* The main use for `IterableArray` would be convenience in handling a collection of objects taking turns at action that could eliminate them from the collection. An example is a table of poker playing dogs.

* The general model I've used to define the behavior of modification during iteration is a batting order/list of the current team at bat (assuming they're allowed to modify it during the game...I dunno about that due to it's some sort of sports thing, I think).

* Creating an `IterableArray`: `ary = IterableArray.new [:dragonflies, :katydids]`.

* For almost all of the methods implemented, an `IterableArray` instance will act identically to the corresponding `Array` instance. The only exception that I am aware of is `#equal?`.

* `#equal?` is class-aware whereas `#==` is not:
````ruby
a = [:a, :b, :c]
#=> [:a, :b, :c]
b = IterableArray.new [:a, :b, :c]
#=> [:a, :b, :c]
b == a
#=> true
b.equal? a
#=> false
````

* If you need to move an element in an `IterableArray` to a different location during iteration, use `#move`, `#move_from`, `#swap!`, or `#swap_indices!` rather than a combination of `#delete_at` and `#insert`. Modification methods generally have to be atomic for logical iteration-awareness to be preserved.

* When an `Array` instance method would return an `Array`, the corresponding `IterableArray` instance method generally returns an `IterableArray`.

* `#to_a` gives direct access to the `Array` object inside an `IterableArray` instance without the iteration-aware wrapper provided by `IterableArray`. This is useful for performing methods not implemented by `IterableArray` or for time-consuming methods that don't require iteration-awareness. (Note that `#to_a` is not an implicit `#dup`. I've been foiled by this fact before. Children, behave and watch how you play!)

* `IterableArray` is slower than `Array`. I'd suspect by quite a lot, but I haven't got into profiling things yet. For a contrived metric, the specs seem to run fast enough.

* Some modifier methods (e.g. `#replace`, `#fill` (when used without a block)) are really just clobberors. They clobber the contents of the array and don't lend to keeping track of 'who left off where'. Iteration will continue with whatever index was calculated through the use of the iteration-aware modifiers.

* No more bullets.

