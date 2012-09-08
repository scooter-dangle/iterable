iterable
========

A(n unfinished) gem providing arrays with [Wikipedia-defined iteration](http://en.wikipedia.org/wiki/Iterator#Contrasting_with_indexing) (as opposed to Wikipedia-defined indexing) via the IterableArray class, where many operations on an array have a defined behavior _while_ the array is being traversed by an iterator method.

Current status (as of 2012 09 06)
---------------------------------

This gem is still under development: don't use it for anything! To see what it does, look at the specs - especially those for complex and nested iteration. The vast majority of the specs currently pass. There are specs for most of the methods implemented.

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

* `#to_a` gives direct access to the `Array` object inside an `IterableArray` instance without the iteration-aware wrapper provided by `IterableArray`. This is useful for performing methods not implemented by `IterableArray` or for time-consuming methods that don't require iteration-awareness. (Note that `#to_a` is not an implicit `#dup`. I've been foiled by this fact before.)

* `IterableArray` is [much] slower than `Array`.

* I'm writing it for 1.9.3 while it's in development.

* No more bullets.

