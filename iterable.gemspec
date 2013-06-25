$:.unshift File.expand_path('../lib', __FILE__)
require 'date'
require 'iterable_array/version'

description = <<EOS
Provides the class IterableArray, which implements all of the methods of Array
(as of Ruby 1.9.3) in an iterable-aware fashion. I.e., behavior is defined to
the greatest extent possible for operations that modify an IterableArray from
within an iteration block (e.g. each, map, delete_if, reverse_each). To use,
call #to_iter on a pre-existing Array or use IterableArray.new; the
IterableArray should act identically to a regular Array except that it
responds logically to modifications during iteration.
EOS

Gem::Specification.new do |o|
    o                .name = 'iterable'
    o             .version = IterableArray::VERSION
    o              .author = 'Scott L Steele'
    o             .license = ''
    o                .date = Date.today.to_s
    o             .summary = 'Provides a fully iterable array object'
    o         .description = description
    o               .email = 'ScottLSteele@gmail.com'
    o            .homepage = 'https://github.com/scooter-dangle/iterable'
    o               .files = Dir['lib{/*,}/*.rb']
end
