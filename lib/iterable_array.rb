# Note: Currently this uses a super sloppy/cluttered approach to adding and removing methods.
# I'd put the methods in modules and extend the IterableArray instance with the appropriate
# module except that removing/unextending a module would require the mixology gem, which currently
# does not work in Rubinius. :(
# Or the remix gem, maybe.
require 'forwardable'

base_path = File.expand_path File.dirname __FILE__

require "#{base_path}/iterable_array/version.rb"

require "#{base_path}/swapable.rb"
require "#{base_path}/array.rb"
# Required for ruby 1.8 compatibility by IterableArray#shuffle! during iteration
require "#{base_path}/sampler.rb" unless [].respond_to? :sample

require "#{base_path}/iterable_array/special_accessors.rb"
require "#{base_path}/iterable_array/iterators.rb"
require "#{base_path}/iterable_array/iterator_specials.rb"
require "#{base_path}/iterable_array/special_modifiers_noniterating.rb"

# The following are not yet modules.
require "#{base_path}/iterable_array/special_modifiers_iterating.rb"
require "#{base_path}/iterable_array/plain_modifiers.rb"

class IterableArray
    extend Forwardable

    # include self::SpecialAccessors
    # include self::Iterators
    include self::IteratorSpecials
    include self::SpecialModifiersNoniterating
    # include self::SpecialModifiersIterating
    # include self::PlainModifiers

    # Most Enumerable instance methods have not been tested to ensure atomic modification
    include Enumerable

    @@iterator_specials = [ :tracking, :tracking=, :invert_tracking, ]

    @@plain_accessors   = [ :frozen?, :==, :[]=, :size, :length, :to_a, :to_s, :to_json, :to_enum, :include?, :hash, :to_ary, :fetch, :inspect, :at, :join, :empty?, :member?, :pack, :shelljoin, ]
    @@plain_accessors.push :choice if Array.new.respond_to? :choice
    @@plain_accessors.push :nitems if Array.new.respond_to? :nitems
    @@special_accessors = [ :<<, :concat, :&, :|, :*, :+, :-, :[], :drop, :dup, :compact, :slice, :<=>, :eql?, :indices, :indexes, :values_at, :assoc, :rassoc, :first, :sort, :last, :flatten, :reverse, :shuffle, :push, :replace, :rotate, :swap, :swap_indices, :take, :transpose, :uniq, ]
    @@special_accessors.push :sample if Array.new.respond_to? :sample

    @@plain_modifiers   = [ :delete, :delete_at, ]
    @@special_modifiers = [ :clear, :compact!, :flatten!, :insert, :move, :move_from, :shift, :shuffle!, :sort!, :sort_by!, :unshift, :pop, :reverse!, :rotate!, :slice!, :swap!, :swap_indices!, :uniq!, ]

    @@iterators = [ :each, :reverse_each, :rindex, :collect, :collect!, :map, :map!, :combination, :cycle, :delete_if, :drop_while, :each_index, :index, :find_index, :keep_if, :each_with_index, :reject!, :reject, :select!, :select, :take_while, :count, :fill, :permutation, :repeated_permutation, :repeated_combination, :product, :zip, ]

    # Enumerable methods not covered by Array => [:sort_by, :grep, :find, :detect, :find_all, :flat_map, :collect_concat, :inject, :reduce, :partition, :group_by, :all?, :any?, :one?, :none?, :min, :max, :minmax, :min_by, :max_by, :minmax_by, :each_entry, :each_slice, :each_cons, :each_with_object, :chunk, :slice_before]

    def_delegators :@array, *@@plain_accessors
    def_delegators :@array, *@@plain_modifiers

    private

    def initialize *args
        @array = Array.new(*args).extend Swapable
        @progenitor = self
    end

    def bastardize
        @array = self.new_with_progenitor @array
        @tracking = 0.5
        class << self
            def_delegators :@array, *@@special_accessors
            def_delegators :@array, *@@iterators
        end
        define_plain_modifiers
        define_special_modifiers_iterating
    end

    def debastardize
        @tracking = nil
        @backward_index, @current_index, @forward_index = nil, nil, nil
        @array = @array.to_a
        remove_methods *@@special_accessors
        remove_methods *@@iterators
        remove_methods *@@plain_modifiers
        remove_methods *@@special_modifiers
    end

    if Class.respond_to? :class_exec and Object.respond_to? :singleton_class
        def remove_methods *ary
            ary.each do |meth|
                singleton_class.class_exec { remove_method meth }
            end
        end
    else
        # Object#singleton_class isn't available in Ruby 1.8
        # The following Ruby 1.8-compatible version is appreciably
        # slower in Ruby 1.9 than the version using Object#singleton_class
        def remove_methods *ary
            ary.each do |methd|
                eval "class << self; remove_method :'#{methd}'; end"
            end
        end
    end

    protected

    # Necessary for allowing nested iteration with modifying iterators (like
    # :delete_if)
    # TODO - After refactoring to be a reference to the progenitor itself
    # rather than a binding, need to simplify this... overly complex right
    # now for what it does...
    def new_with_progenitor array
        iter_ary = IterableArray.new array
        iter_ary.take_progenitor @progenitor
        iter_ary
    end

    # Not sure this method is worth the trouble
    def take_progenitor progenitor
        @progenitor = progenitor
        class << self; undef_method :take_progenitor; end
    end

    public

    def to_iter
        self
    end
end

