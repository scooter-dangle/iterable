iterable
========

A(n unfinished) gem providing arrays with [Wikipedia-defined iteration](http://en.wikipedia.org/wiki/Iterator#Contrasting_with_indexing) (as opposed to Wikipedia-defined indexing) via the IterableArray class, where many operations on an array have a defined behavior _while_ the array is being traversed by an iterator method.

Current status (as of 2012 01 09)
---------------------------------

This gem is **nowhere** near complete! Don't use it for anything! To see what it does, look at the spec: it currently fails (almost) everything within `describe 'complex iteration' do`. Everything else passes.

Motivation
----------

Testing Rubninius by running on it some of the little Ruby projects I've made, I found that my answer to the extra credit [koan](http://rubykoans.com) wasn't terminating because `cycle` kept iterating through an empty player array. I hadn't realized that iterator behavior isn't always defined when you modify the array during iteration, and I wanted to see how far I could get in allowing that behavior to be defined.

It's been pretty suite/fun to work on as I believe it's the first thing I've written in Ruby that would be difficult for me to write in any other language I've tinkered much in as it relies heavily on Ruby's dynamic object model.

