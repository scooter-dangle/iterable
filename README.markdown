iterable
========

A(n unfinished) gem providing arrays with [Wikipedia-defined iteration](http://en.wikipedia.org/wiki/Iterator#Contrasting_with_indexing) (as opposed to Wikipedia-defined indexing) via the IterableArray class, where many operations on an array have a defined behavior _while_ the array is being traversed by an iterator method.

Current status (as of 2012 01 16)
---------------------------------

This gem has **extremely** limited functionality and is still under development: don't use it for anything! To see what it does, look at the spec: it currently fails 2 tests within `describe 'complex iteration' do`. Everything else passes.

Motivation
----------

Testing Rubninius by running on it some Ruby tutorials I've followed, I found that my answer to the extra credit [koan](http://rubykoans.com) wasn't terminating because `cycle` kept iterating through an empty player array. I hadn't realized that iterator behavior isn't always defined when you modify the array during iteration, and I wanted to see how far I could get in allowing that behavior to be defined.

It's been pretty suite/fun/addictive to work on as I believe it's the first thing I've written in any language that has required an understanding of a design feature peculiar to that language (as opposed to just control-flow / glue code scripts I've made before). In particular, it depends on Ruby's support for a fully dynamic object model.

