# Note: Currently this uses a super sloppy/cluttered approach to adding and removing methods.
# I'd put the methods in modules and extend the IterableArray instance with the appropriate
# module except that removing/unextending a module would require the mixology gem, which currently
# does not work in Rubinius. :(

require "#{File.dirname(File.expand_path __FILE__)}/swappy_array.rb"
require 'forwardable'

class IterableArray
    extend Forwardable

    # Most Enumerable instance methods have not been tested to ensure atomic modification
    include Enumerable

    # attr_accessor :array  # For testing purposes only! And even then, what are you doing?!

    @@iterator_specials = [ :tracking, :tracking=, :invert_tracking, ]

    @@plain_accessors   = [ :frozen?, :==, :[]=, :size, :length, :to_a, :to_s, :to_enum, :include?, :hash, :to_ary, :fetch, :inspect, :at, :join, :empty?, :entries, :member?, ]
    @@special_accessors = [ :<<, :concat, :&, :|, :*, :+, :-, :[], :drop, :dup, :compact, :sample, :slice, :<=>, :eql?, :indices, :indexes, :values_at, :assoc, :rassoc, :first, :sort, :last, :reverse, :shuffle, :push, :rotate, :swap, :swap_indices, :take, :uniq, ]

    @@plain_modifiers   = [ :delete, :delete_at, :pop ]
    @@special_modifiers = [ :clear, :compact!, :insert, :move, :move_from, :shift, :shuffle!, :sort!, :unshift, :reverse!, :rotate!, :slice!, :swap!, :swap_indices!, :uniq!, ]

    @@iterators = [ :each, :reverse_each, :rindex, :collect, :collect!, :map, :map!, :combination, :cycle, :delete_if, :drop_while, :each_index, :index, :keep_if, :each_with_index, :reject!, :reject, :select!, :select, :take_while, :count, :fill, :permutation, :repeated_permutation, :repeated_combination, ]
    # TODO :find_index, :sort_by!, :zip, :transpose, :replace,

    # The following two lines are supposed to help me keep track of progress.
    # working:  Array#instance_methods(false) => [:find_index, :sort_by!, :zip, :transpose, :replace, :flatten, :flatten!, :product, :pack]
    # original: Array#instance_methods(false) => [:inspect, :to_s, :to_a, :to_ary, :frozen?, :==, :eql?, :hash, :[], :[]=, :at, :fetch, :first, :last, :concat, :<<, :push, :pop, :shift, :unshift, :insert, :each, :each_index, :reverse_each, :length, :size, :empty?, :find_index, :index, :rindex, :join, :reverse, :reverse!, :rotate, :rotate!, :sort, :sort!, :sort_by!, :collect, :collect!, :map, :map!, :select, :select!, :keep_if, :values_at, :delete, :delete_at, :delete_if, :reject, :reject!, :zip, :transpose, :replace, :clear, :fill, :include?, :<=>, :slice, :slice!, :assoc, :rassoc, :+, :*, :-, :&, :|, :uniq, :uniq!, :compact, :compact!, :flatten, :flatten!, :count, :shuffle!, :shuffle, :sample, :cycle, :permutation, :combination, :repeated_permutation, :repeated_combination, :product, :take, :take_while, :drop, :drop_while, :pack]
    # Enumerable methods not covered by Array => [:sort_by, :grep, :find, :detect, :find_all, :flat_map, :collect_concat, :inject, :reduce, :partition, :group_by, :all?, :any?, :one?, :none?, :min, :max, :minmax, :min_by, :max_by, :minmax_by, :each_entry, :each_slice, :each_cons, :each_with_object, :chunk, :slice_before]

    def_delegators :@array, *@@plain_accessors
    def_delegators :@array, *@@plain_modifiers

    private

    def initialize *args
        @array = SwappyArray.new *args
        @progenitor_binding = binding
        define_iterators
        define_special_accessors
        define_special_modifiers_noniterating
    end

    def bastardize
        @array = self.new_with_binding @array
        @tracking = 0.5
        undefine_methods *@@iterators
        undefine_methods *@@special_accessors
        undefine_methods *@@special_modifiers
        class << self
            def_delegators :@array, *@@special_accessors
            def_delegators :@array, *@@iterators
        end
        define_plain_modifiers
        define_special_modifiers_iterating
        define_iterator_specials
    end

    def debastardize
        @tracking = nil
        @backward_index, @current_index, @forward_index = nil, nil, nil
        @array = @array.to_a
        undefine_methods *@@plain_modifiers
        undefine_methods *@@special_modifiers
        undefine_methods *@@iterator_specials
        class << self
            def_delegators :@array, *@@plain_modifiers
        end
        define_special_accessors
        define_special_modifiers_noniterating
        define_iterators
    end

    def define_special_accessors
        class << self
            def << arg
                @array << arg
                self
            end

            def concat arg
                arg.each { |x| @array << x }
                self
            end

            def [](arg1, arg2=nil)
                case arg1

                when Fixnum
                    return @array.at(arg1) unless arg2

                    IterableArray.new @array[arg1, arg2]

                when Range
                    IterableArray.new @array[arg1]
                end
            end

            alias_method :slice, :[]

            def drop n
                IterableArray.new @array.drop n
            end

            # untested
            def dup
                IterableArray.new @array.to_a.dup
            end

            def first n = nil
                return @array.first if n == nil
                IterableArray.new @array.first(n)
            end

            def last n = nil
                return @array.last if n == nil
                IterableArray.new @array.last(n)
            end

            # What should I use for the default argument here?
            # (What if someone really wants to push `nil` onto the array?)
            # See also: #rindex
            def push obj = nil
                @array.push obj unless obj == nil
                self
            end

            # untested
            def compact
                IterableArray.new @array.compact
            end

            # It looks like Array#assoc and Array#rassoc return
            # Array versions of their elements when they find a
            # match. I'm not sure why that is... You'd think it
            # would be more duck-typish to maintain the object's
            # class, right? I dunno why it has to be so sad.
            def assoc obj
                each do |x|
                    if x.respond_to? :at and x.at(0) == obj
                        return x
                    end
                end

                nil
            end

            # See note above assoc.
            def rassoc obj
                each do |elem|
                    if elem.respond_to? :at and elem.at(1) == obj
                        return elem
                    end
                end

                nil
            end

            # Not defined since Array#nitems is not defined in 1.9.2+
            # def nitems
            # end

            def & arg
                IterableArray.new(@array & arg.to_a)
            end

            def | arg
                IterableArray.new(@array | arg.to_a)
            end

            def + arg
                IterableArray.new(@array + arg)
            end

            def - arg
                IterableArray.new(@array - arg)
            end

            def * arg
                return IterableArray.new @array * arg if arg.kind_of? Fixnum
                @array * arg
            end

            def <=>(other)
                return @array <=> other.to_a if other.kind_of? IterableArray
                @array <=> other
            end

            def values_at *args
                out = IterableArray.new
                args.each do |arg|
                    out += @array.values_at arg
                end
                out
            end

            alias_method :indices, :values_at
            alias_method :indexes, :values_at

            def sample arg = nil
                return IterableArray.new(@array.sample arg) unless arg == nil
                IterableArray.new @array.sample
            end

            # :eql? returns true only when array contents are the same and
            # both objects are IterableArray instances
            def eql? arg
                (arg.class == IterableArray) and
                    (self == arg.to_a)
            end

            # untested
            def reverse
                IterableArray.new @array.reverse
            end

            # untested
            def rotate n = 1
                IterableArray.new @array.rotate(n)
            end

            def sort
                IterableArray.new @array.sort
            end

            def shuffle
                IterableArray.new @array.shuffle
            end

            def swap *args
                IterableArray.new @array.swap(*args)
            end

            def swap_indices *args
                IterableArray.new @array.swap_indices(*args)
            end

            # untested
            def take n
                IterableArray.new @array.take(n)
            end

            # untested
            def uniq
                IterableArray.new @array.uniq
            end
        end
    end

    def define_special_modifiers_noniterating
        class << self
            # untested
            def compact!
                @array.compact!
                self
            end

            def clear
                @array.clear
                self
            end

            def shift n = nil
                return @array.shift if n == nil

                IterableArray.new @array.shift(n)
            end

            def insert location, *items
                @array.insert location, *items
                self
            end

            # untested
            def move element, to
                @array.move element, to
                self
            end

            # untested
            def move_from from, to
                @array.move_from from, to
                self
            end

            def reverse!
                @array.reverse!
                self
            end

            # untested
            def rotate! n = 1
                @array.rotate! n
                self
            end

            def sort!
                @array.sort!
                self
            end

            def shuffle!
                @array.shuffle!
                self
            end

            def slice! *args
                if args.length == 2 or args.at(1).kind_of? Range
                    IterableArray.new @array.slice!(*args)
                else
                    @array.slice!(*args)
                end
            end

            def unshift *args
                @array.insert 0, *args
                self
            end

            def swap! *args
                @array.swap! *args
                self
            end

            def swap_indices! *args
                @array.swap_indices! *args
                self
            end

            # untested
            def uniq!
                @array.uniq!
                self
            end
        end
    end

    def define_special_modifiers_iterating
        class << self
            def clear
                @backward_index -= @current_index
                @forward_index  -= @current_index
                @current_index   = 0
                @array.clear
            end

            # untested
            def compact!
                delete_if &:nil?
                self
            end

            def shift n = nil
                return self.delete_at(0) if n == nil

                out = IterableArray.new
                [ n, @array.length ].min.times { out << self.delete_at(0) }
                out
            end

            def insert location, *items
                location = size + location if location < 0

                @array.insert location, *items  # I put this here rather than at the end
                                                # so that any possible location error is raised
                                                # before modifying the indices.

                center_indices_at(@current_index + items.size) if location <= @current_index

                self
            end

            # untested
            def move element, to
                from = index element
                move_from from, to
            end

            # untested
            def move_from from, to
                if from == @current_index then
                    center_indices_at to
                elsif from < @current_index and to >= @current_index
                    center_indices_at(@current_index - 1)
                elsif from > @current_index and to <= @current_index
                    center_indices_at(@current_index + 1)
                end
                @array.move_from from, to
            end

            def slice! start, length=:undefined
                if length.equal? :undefined
                    if start.kind_of? Range
                        out = IterableArray.new @array.slice(start)
                        first, last = start.first, start.last
                        first += @array.length if first < 0
                        last  += @array.length if last  < 0
                        if first <= last
                            length = last - first
                            length += 1 unless start.exclude_end?
                            length.times { delete_at first }
                        end
                    else
                        out = delete_at start
                    end
                else
                    out = IterableArray.new @array.slice(start, length)
                    start += @array.length if start < 0
                    length.times { delete_at start }
                end
                out
            end

            def unshift *args
                insert 0, *args
                self
            end

            def reverse!
                @backward_index, @forward_index =
                    @array.size - 1 - @forward_index,
                    @array.size - 1 - @backward_index

                # @current_index = @backward_index  + 1
                @current_index = @array.size - 1 - @current_index

                @current_index = case @current_index
                                 when @backward_index then @forward_index
                                 when @forward_index  then @backward_index
                                                      else @current_index
                                 end

                invert_tracking

                @array.reverse!
                self
            end

            # partially tested (not tested nested)
            def rotate! n = 1
                n %= size
                return self if n == 0
                new_index = (@current_index - n) % size
                center_indices_at new_index
                @array.rotate! n
            end

            def sort!
                return @array.sort! if @current_index >= @array.size or @current_index < 0

                current_item = @array.at @current_index
                offset = @array.to_a[0...@current_index].count current_item

                @array.sort!

                center_indices_at (@array.to_a.index(current_item) + offset)

                self
            end

            def shuffle!
                return @array.shuffle! if @current_index >= @array.size or @current_index < 0

                current_item = @array.at @current_index
                count = @array.to_a.count current_item

                @array.shuffle!

                locations = []
                @array.to_a.each_with_index { |item, location| locations << location if item == current_item }

                center_indices_at locations.sample

                self
            end

            def swap! *args
                args.map! { |x| index x }
                swap_indices! *args
            end

            def swap_indices! *args
                args.inject { |i1, i2| swap_2_indices!(i1, i2); i2 }
                self
            end
            alias_method :swap_indexes!, :swap_indices!

            # untested
            def uniq!
                basket = []
                delete_if do |x| 
                    if basket.include? x
                        true
                    else
                        basket << x
                        false
                    end
                end
                self
            end

            protected
            def swap_2_indices! arg1, arg2
                temp_holder = @current_index
                center_indices_at(arg1) if temp_holder == arg2
                center_indices_at(arg2) if temp_holder == arg1
                @array.swap_indices! arg1, arg2
            end

            private
            def center_indices_at new_index
                movement = @current_index - new_index
                @current_index  -= movement
                @forward_index  -= movement
                @backward_index -= movement
            end
        end
    end

    def define_iterator_specials
        class << self
            # specials
            # TODO: either ensure that the following methods are being undefined
            # during #debastardize or make them private... currently they aren't
            # being undefined.
            # TODO: Also, these currently fail in a nested iteration block if they're
            # called from the main instance of IterableArray...they'll only affect
            # the outermost iteration block when called by a user (but they should
            # work fine when called internally)
            public
            # Need to add some minimal documentation on tracking.
            # untested
            def invert_tracking
                @tracking *= -1
                tracking
            end

            # untested
            def tracking
                case @tracking < 0
                when true  then :aft
                when false then :fore
                end
            end

            # untested
            def tracking= orient
                @tracking = case orient
                            when :aft  then @tracking.abs * -1
                            when :fore then @tracking.abs
                            end
                tracking
            end
        end
    end

    def define_plain_modifiers
        class << self
            def delete_at location
                # Flip to positive and weed out out of bounds
                location += @array.size if location < 0
                return nil if location < 0 or location >= @array.size

                @forward_index  -= 1 if location < @forward_index
                @current_index  -= 1 if location < @current_index - @tracking
                @backward_index -= 1 if location < @backward_index

                @array.delete_at location
            end

            # currently untested
            def delete obj
                n = count obj
                if n == 0
                    return yield(obj) if block_given?
                    nil
                else
                    n.times { delete_at index obj }
                    obj
                end
            end

            def pop n = 1
                return delete_at(size - 1) if n == 1

                out = IterableArray.new []
                n.times { out.unshift pop }
                out
            end
        end
    end

    def define_iterators
        class << self
            private
            def catch_a_break
                result = nil
                begin
                    bastardize
                    result = yield
                ensure
                    debastardize
                end
                result
            end

            def increment_indices
                @current_index  = @forward_index
                @forward_index  = @current_index + 1
                @backward_index = @current_index - 1
            end

            public

            # untested and not a pretty sight in general
            # When used without a block, `#fill` is not iteration aware
            # as its default behavior is similar to that of `#replace`---
            # which is a clobberor.
            def fill *args    # obj=nil, start_or_range=nil, lengther=nil
                return @array.fill *args unless block_given?

                #######################
                # Argument processing #
                #######################
                args[0] = 0 if args.empty?

                raise ArgumentError if
                    args.size > 2 or
                    (args.first.kind_of? Range and args.size != 1)

                if args.first.kind_of? Range then
                    args[1] = args.first.exclude_end? ?
                              args.first.last - 1 :
                              args.first.last
                    args[0] = args.first.first
                end

                ##################################################
                # Translating argument array to iteration bounds #
                ##################################################
                starter = args.first
                the_final = args.at 1
                ender = -> { the_final or length }

                #############
                # Iteration #
                #############
                catch_a_break do
                    @current_index = starter
                    @backward_index, @forward_index = @current_index - 1, @current_index + 1
                    while @current_index < ender[]
                        index_to_fill = @current_index
                        self[index_to_fill] = yield @current_index
                        increment_indices
                    end
                    self
                end
            end

            # untested
            def drop_while
                return @array.to_enum :drop_while unless block_given?

                out = IterableArray.new
                dropping = true
                each do |x|
                    dropping = yield x if dropping
                    out << x unless dropping
                end
                out
            end

            # untested
            def select
                return @array.to_enum(:select) unless block_given?
                out = IterableArray.new
                each { |x| out << x if yield x }
                out
            end

            # untested
            def select!
                return @array.to_enum(:select) unless block_given?
                original = @array.to_a.dup
                delete_if { |x| not yield x }
                return nil if self == original
                self
            end

            # untested
            def keep_if
                return @array.to_enum(:keep_if) unless block_given?
                delete_if { |x| not yield x }
            end

            # untested
            def count arg = :undefined
                if arg == :undefined
                    return @array.length  unless block_given?
                    counter = 0
                    each { |x| counter += 1 if yield x }
                    counter
                else
                    @array.to_a.count arg
                end
            end

            def each
                return @array.to_enum(:each) unless block_given?

                catch_a_break do
                    @backward_index, @current_index, @forward_index = -1, 0, 1
                    while @current_index < @array.size
                        yield @array.at(@current_index)
                        increment_indices
                    end

                    self
                end
            end

            def each_index
                return @array.to_enum(:each_index) unless block_given?

                catch_a_break do
                    @backward_index, @current_index, @forward_index = -1, 0, 1
                    while @current_index < @array.size
                        yield @current_index
                        increment_indices
                    end

                    self
                end
            end

            def each_with_index
                return @array.to_enum(:each_with_index) unless block_given?

                catch_a_break do
                    @backward_index, @current_index, @forward_index = -1, 0, 1
                    while @current_index < @array.size
                        yield @array.at(@current_index), @current_index
                        increment_indices
                    end

                    self
                end
            end

            # Should delete_if be smarter / more magical than this?
            # I had considered having it test for whether an element
            # it is going to delete has already been deleted while
            # it was yielded to the iteration block. Doing so would
            # be something of a wild-goose chase but then so is this
            # entire project. I don't know if making it more 'magical'
            # would make its behavior more or less predictable to the
            # end user.
            def delete_if        # Rubinius includes `&block` as an argument, but I don't know why
                return @array.to_enum(:delete_if) unless block_given?

                catch_a_break do
                    @backward_index, @current_index, @forward_index = -1, 0, 1
                    while @current_index < @array.size

                        # Usage of binding is necessary since this current :delete_if
                        # call might be operating inside several levels of nested
                        # iteration. If we just used :delete_at here, those higher
                        # iteration levels would not be able to adjust their indices
                        # to account for the change in array size.
                        if yield @array.at(@current_index)
                            @progenitor_binding.eval "self.delete_at #{@current_index}"
                        end
                        increment_indices
                    end

                    self
                end
            end

            # untested
            def reject!
                return @array.to_enum(:reject!) unless block_given?
                original = @array.to_a.dup
                delete_if { |x| yield x }
                return nil if self == original
                self
            end

            # untested
            def reject
                return @array.to_enum(:reject) unless block_given?
                out = IterableArray.new
                each { |x| out << x unless yield x }
                out
            end

            # untested
            # need to fix default argument to allow folks to search for nil
            def rindex obj = nil
                if obj.nil?
                    return @array.to_enum(:rindex) unless block_given?

                    catch_a_break do
                        invert_tracking
                        @current_index = @array.size - 1
                        @backward_index, @forward_index = @current_index - 1, @current_index + 1
                        while @current_index >= 0
                            return @current_index if yield @array.at @current_index

                            @current_index  = @backward_index
                            @forward_index  = @current_index + 1
                            @backward_index = @current_index - 1
                        end
                        nil
                    end
                else
                    @array.rindex obj
                end
            end

            def reverse_each
                return @array.to_enum(:reverse_each) unless block_given?

                catch_a_break do
                    invert_tracking
                    @current_index = @array.size - 1
                    @backward_index, @forward_index = @current_index - 1, @current_index + 1
                    while @current_index >= 0
                        yield @array.at @current_index

                        @current_index  = @backward_index
                        @forward_index  = @current_index + 1
                        @backward_index = @current_index - 1
                    end

                    self
                end
            end

            # untested
            def take_while
                return @array.to_enum(:take_while) unless block_given?
                out = IterableArray.new
                each { |x| break unless yield x; out << x }
                out
            end

            def map
                return @array.dup unless block_given?
                out = IterableArray.new

                catch_a_break do
                    @backward_index, @current_index, @forward_index = -1, 0, 1
                    while @current_index < @array.size
                        out << yield(@array.at @current_index)
                        increment_indices
                    end

                    out
                end
            end

            alias_method :collect, :map

            def map!
                return to_enum(:map!) unless block_given?

                catch_a_break do
                    @backward_index, @current_index, @forward_index = -1, 0, 1
                    while @current_index < @array.size
                        # The following verbosity required so that @current_index will be
                        # evaluated after any modifications to it by the block.
                        temp_value = yield(@array.at @current_index)
                        @array[@current_index] = temp_value
                        increment_indices
                    end

                    self
                end
            end

            alias_method :collect!, :map!

            def cycle n = nil, &block
                return @array.to_enum(:cycle, n) unless block_given?

                catch_a_break do
                    if n.equal? nil
                        until @array.empty?
                            @backward_index, @current_index, @forward_index = -1, 0, 1
                            while @current_index < @array.size
                                yield @array.at(@current_index)
                                increment_indices
                            end
                        end
                    else
                        n.times do
                            @backward_index, @current_index, @forward_index = -1, 0, 1
                            while @current_index < @array.size
                                yield @array.at(@current_index)
                                increment_indices
                            end
                        end
                    end

                    nil
                end
            end

            def index obj = :undefined
                unless block_given?
                    # What should I change :undefined to?
                    # I can't use null or nil or anything in case the index
                    # of null or nil needs to be looked up.
                    # Rubinius uses a plain (non-symbol) 'undefined' keyword,
                    # but that doesn't seem to work in 1.9.2.
                    return @array.index(obj) unless obj == :undefined
                    return @array.to_enum(:index)
                end

                catch_a_break do
                    @backward_index, @current_index, @forward_index = -1, 0, 1
                    while @current_index < @array.size
                        return @current_index if yield @array.at(@current_index)
                        increment_indices
                    end

                    nil
                end
            end

            # Currently only defined for arrays `a` where `a.uniq == a`
            def permutation n = @array.size, &block
                comb_perm_helper :permutation, n, &block
            end

            # Currently only defined for arrays `a` where `a.uniq == a`
            def combination n, &block
                comb_perm_helper :combination, n, &block
            end

            # Currently only defined for arrays `a` where `a.uniq == a`
            def repeated_permutation n = @array.size, &block
                comb_perm_helper :repeated_permutation, n, &block
            end

            # Currently only defined for arrays `a` where `a.uniq == a`
            def repeated_combination n, &block
                comb_perm_helper :repeated_combination, n, &block
            end

            private
            def comb_perm_helper methd, n
                return @array.to_enum(methd, n) unless block_given?
                @backward_index, @current_index, @forward_index = 0, 0, 0

                catch_a_break do
                    queue = comb_perm_generator methd, to_a, n
                    history = []
                    until queue.empty?
                        element = queue.shift
                        previous = to_a.sort
                        yield element
                        history.push element
                        queue = diff_handler queue, history, previous, methd, n unless to_a.sort == previous
                    end
                    self
                end
            end

            def comb_perm_generator methd, ary, n
                out = []
                ary.method(methd)[ n, &(->(item) {
                    out << item
                }) ]
                out
            end

            # only for :permutation/:combination and their cousins
            def diff_handler queue, history, previous, methd, n
                deleted_items = previous - self
                new_items = self - previous
                queue = remove_deleted_items queue, deleted_items
                queue = add_new_items queue, history, new_items, methd, n
                queue
            end

            # only for :permutation/:combination and their cousins
            def add_new_items queue, history, items, methd, n
                new_elements = comb_perm_generator methd, to_a, n
                new_elements -= history
                queue += new_elements
                queue
            end

            # only for :permutation/:combination and their cousins
            def remove_deleted_items queue, items
                items.each do |item|
                    queue.delete_if { |x| x.include? item }
                end
                queue
            end
        end
    end

    def undefine_methods *ary
        ary.each do |meth|
            singleton_class.class_exec {
                begin
                    undef_method meth
                rescue # begin/rescue should be unnecessary once I've defined all the methods
                    print "undef_method failed for #{meth}\n"
                end
            }
        end
    end

    # :method_missing should probably be disabled during testing. Is
    # there a more elegant / built-in way to do this?
#    def method_missing  method, *args, &block 
#        @array.send( method, *args, &block )
#    end

    protected

    # Necessary for allowing nested iteration with modifying iterators (like
    # :delete_if)
    def new_with_binding array
        iter_ary = IterableArray.new array
        iter_ary.take_progenitor_binding @progenitor_binding
        iter_ary
    end

    def take_progenitor_binding progenitor_binding
        @progenitor_binding = progenitor_binding
        class << self; undef_method :take_progenitor_binding; end
    end
end

