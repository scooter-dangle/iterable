# Note: Currently this uses a super sloppy/cluttered approach to adding and removing methods.
# I'd put the methods in modules and extend the IterableArray instance with the appropriate
# module except that removing/unextending a module would require the mixology gem, which currently
# does not work in Rubinius. :(

require 'forwardable'

class IterableArray
    extend Forwardable

    # Probably won't be able to take advantage of Enumerable :(
    # include Enumerable

    # attr_accessor :array  # For testing purposes only! And even then, what are you doing?!

    @@plain_accessors   = [ :==, :[]=, :size, :length, :to_a, :to_s, :to_enum, :include?, :hash, :to_ary, :fetch, :inspect, :at, :empty? ]
    @@special_accessors = [ :&, :|, :*, :+, :-, :[], :<=>, :eql?, :indices, :indexes, :values_at, :join, :assoc, :rassoc, :first, :last, :reverse, :push ]

    @@plain_modifiers   = [ :delete, :delete_at, :pop ]
    @@special_modifiers = [ :<<, :shift, :reverse! ]

    @@iterators = [ :each, :reverse_each, :collect, :collect!, :map, :map!, :combination, :count, :cycle, :delete_if, :drop_while, :each_index, :each_with_index, :select ]

    # @@hybrids contains methods that fit into the previous groups depending
    # on the arguments passed.

    @@hybrids   = [ :fill, :index ]

    # The following two lines are supposed to help me keep track of progress.
    # working:  Array#public_instance_methods => [ :frozen?, :concat, :unshift, :insert, :find_index, :rindex, :rotate, :rotate!, :sort, :sort!, :sort_by!, :select!, :keep_if, :delete_if, :reject, :reject!, :zip, :transpose, :replace, :clear, :slice, :slice!, :uniq, :uniq!, :compact, :compact!, :flatten, :flatten!, :shuffle!, :shuffle, :sample, :permutation, :repeated_permutation, :repeated_combination, :product, :take, :take_while, :drop, :pack, :entries, :sort_by, :grep, :find, :detect, :find_all, :flat_map, :collect_concat, :inject, :reduce, :partition, :group_by, :all?, :any?, :one?, :none?, :min, :max, :minmax, :min_by, :max_by, :minmax_by, :member?, :each_entry, :each_slice, :each_cons, :each_with_object, :chunk, :slice_before, :nil?, :===, :=~, :!~, :clone, :dup, :freeze, :tap, :extend, :display, :enum_for, :!, :!= ]
    # original: Array#public_instance_methods => [ :inspect, :to_s, :to_a, :to_ary, :frozen?, :==, :eql?, :hash, :[], :[]=, :at, :fetch, :first, :last, :concat, :<<, :push, :pop, :shift, :unshift, :insert, :each, :each_index, :reverse_each, :length, :size, :empty?, :find_index, :index, :rindex, :join, :reverse, :reverse!, :rotate, :rotate!, :sort, :sort!, :sort_by!, :collect, :collect!, :map, :map!, :select, :select!, :keep_if, :values_at, :delete, :delete_at, :delete_if, :reject, :reject!, :zip, :transpose, :replace, :clear, :fill, :include?, :<=>, :slice, :slice!, :assoc, :rassoc, :+, :*, :-, :&, :|, :uniq, :uniq!, :compact, :compact!, :flatten, :flatten!, :count, :shuffle!, :shuffle, :sample, :cycle, :permutation, :combination, :repeated_permutation, :repeated_combination, :product, :take, :take_while, :drop, :drop_while, :pack, :entries, :sort_by, :grep, :find, :detect, :find_all, :flat_map, :collect_concat, :inject, :reduce, :partition, :group_by, :all?, :any?, :one?, :none?, :min, :max, :minmax, :min_by, :max_by, :minmax_by, :member?, :each_with_index, :each_entry, :each_slice, :each_cons, :each_with_object, :chunk, :slice_before, :nil?, :===, :=~, :!~, :class, :singleton_class, :clone, :dup, :initialize_dup, :initialize_clone, :taint, :tainted?, :untaint, :untrust, :untrusted?, :trust, :freeze, :methods, :singleton_methods, :protected_methods, :private_methods, :public_methods, :instance_variables, :instance_variable_get, :instance_variable_set, :instance_variable_defined?, :instance_of?, :kind_of?, :is_a?, :tap, :send, :public_send, :respond_to?, :respond_to_missing?, :extend, :display, :method, :public_method, :define_singleton_method, :__id__, :object_id, :to_enum, :enum_for, :equal?, :!, :!=, :instance_eval, :instance_exec, :__send__ ]

    def_delegators :@array, *@@plain_accessors
    def_delegators :@array, *@@plain_modifiers

    private # Only comment out for testing purposes.

    def initialize array = []
        @array = Array.new array
        @progenitor_binding = binding
        define_iterators
        define_special_accessors
        define_special_modifiers_noniterating
    end

    def bastardize
        @array = self.new_with_binding @array
        undefine_methods @@iterators
        undefine_methods @@special_accessors
        undefine_methods @@special_modifiers
        class << self
            def_delegators :@array, *@@special_accessors
            def_delegators :@array, *@@iterators
        end
        define_plain_modifiers
        define_special_modifiers_iterating
    end

    def debastardize
        @array = @array.to_a
        undefine_methods @@plain_modifiers
        undefine_methods @@special_modifiers
        class << self
            def_delegators :@array, *@@plain_modifiers
        end
        define_special_accessors
        define_special_modifiers_noniterating
        define_iterators
    end

    def define_special_accessors
        class << self
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

            def first n = nil
                return @array.first if n == nil
                IterableArray.new @array.first(n)
            end

            def last n = nil
                return @array.last if n == nil
                IterableArray.new @array.last(n)
            end

            def assoc obj
                each do |x|
                    if x.respond_to? :at and x.at(0) == obj
                        return x
                    end
                end

                nil
            end

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

            def &(arg)
                IterableArray.new(@array & arg.to_a)
            end

            def |(arg)
                IterableArray.new(@array | arg.to_a)
            end

            def +(arg)
                IterableArray.new(@array + arg)
            end

            def -(arg)
                IterableArray.new(@array - arg)
            end

            def *(arg)
                return IterableArray.new @array * arg if arg.kind_of? Fixnum
                @array * arg
            end

            def <=>(other)
                return @array <=> other.to_a if other.kind_of? IterableArray
                @array <=> other
            end

            def values_at *args
                out = []
                args.each do |arg|
                    out += @array.values_at(arg)
                end
                IterableArray.new out
            end

            alias_method :indices, :values_at
            alias_method :indexes, :values_at

            # :join is defined here (instead of directly delegating it to
            # @array) since we might want to later define how it handles
            # an array that contains IterableArrays as elements.
            def join sep=nil
                @array.join(sep)
            end

            # :eql? returns true only when array contents are the same and
            # both objects are IterableArray instances
            def eql?(arg)
                (arg.class == IterableArray) and
                    (self == arg.to_a)
            end

            # Don't yet have any cases where push should be treated
            # specially during iteration, although I'll need to keep an
            # eye on it.
            # Also, what should I use for the default argument here?
            # (What if someone really wants to push `nil` onto the array?)
            def push obj = nil
                @array.push obj unless obj == nil
                self
            end
        end
    end

    def define_special_modifiers_noniterating
        class << self
            def <<(arg)
                @array << arg
                self
            end

            def shift n = nil
                return @array.shift if n == nil

                IterableArray.new @array.shift(n)
            end
        end
    end

    def define_special_modifiers_iterating
        class << self
            def <<(arg) # Not yet defined
                # @array << arg
            end

            def shift n = nil
                return self.delete_at(0) if n == nil

                out = []
                [ n, @array.length ].min.times { out << self.delete_at(0) }
                IterableArray.new out
            end
        end
    end

    def define_plain_modifiers
        class << self
#            def pop
#            end

#            def push value
#            end

            def delete_at index
                # Flip to positive and weed out out of bounds
                index += @array.size if index < 0
                return nil if index < 0 or index >= @array.size

                @forward_index -= 1 if index < @forward_index
                if index < @current_index
                    @current_index -= 1
                    @backward_index -= 1
                end

                @array.delete_at index
            end
        end
    end

    def define_iterators
        class << self
            def each
                return @array.to_enum(:each) unless block_given?
                bastardize

                @backward_index, @current_index, @forward_index = -1, 0, 1
                while @current_index < @array.size
                    yield @array.at(@current_index)

                    @current_index  = @forward_index
                    @forward_index  = @current_index + 1
                    @backward_index = @current_index - 1
                end

                debastardize
                self
            end

            def each_index
                return @array.to_enum(:each_index) unless block_given?
                bastardize

                @backward_index, @current_index, @forward_index = -1, 0, 1
                while @current_index < @array.size
                    yield @current_index

                    @current_index  = @forward_index
                    @forward_index  = @current_index + 1
                    @backward_index = @current_index - 1
                end

                debastardize
                self
            end

            def each_with_index
                return @array.to_enum(:each_with_index) unless block_given?
                bastardize

                @backward_index, @current_index, @forward_index = -1, 0, 1
                while @current_index < @array.size
                    yield @array.at(@current_index), @current_index

                    @current_index  = @forward_index
                    @forward_index  = @current_index + 1
                    @backward_index = @current_index - 1
                end

                debastardize
                self
            end

            def reverse_each
                return @array.to_enum(:reverse_each) unless block_given?
                bastardize

                @current_index = @array.size - 1
                @backward_index, @forward_index = @current_index - 1, @current_index + 1
                while @current_index >= 0
                    yield @array.at @current_index

                    @current_index  = @backward_index
                    @forward_index  = @current_index + 1
                    @backward_index = @current_index - 1
                end

                debastardize
                self
            end

            def map
                return @array.dup unless block_given?
                out = Array.new []
                bastardize

                @backward_index, @current_index, @forward_index = -1, 0, 1
                while @current_index < @array.size
                    out << yield(@array.at(@current_index))

                    @current_index  = @forward_index
                    @forward_index  = @current_index + 1
                    @backward_index = @current_index - 1
                end

                debastardize
                IterableArray.new out
            end

            alias_method :collect, :map

            def map!
                return to_enum(:map!) unless block_given?
                bastardize

                @backward_index, @current_index, @forward_index = -1, 0, 1
                while @current_index < @array.size
                    # The following verbosity required so that @current_index will be
                    # evaluated after any modifications to it by the block.
                    temp_value = yield(@array.at(@current_index))
                    @array[@current_index] = temp_value

                    @current_index  = @forward_index
                    @forward_index  = @current_index + 1
                    @backward_index = @current_index - 1
                end

                debastardize
                self
            end

            alias_method :collect!, :map!

            def cycle n = nil, &block
                return @array.to_enum(:cycle, n) unless block_given?
                bastardize

                if n.equal? nil
                    until @array.empty?
                        @backward_index, @current_index, @forward_index = -1, 0, 1
                        while @current_index < @array.size
                            yield @array.at(@current_index)

                            @current_index  = @forward_index
                            @forward_index  = @current_index + 1
                            @backward_index = @current_index - 1
                        end
                    end
                else
                    n.times do
                        @backward_index, @current_index, @forward_index = -1, 0, 1
                        while @current_index < @array.size
                            yield @array.at(@current_index)

                            @current_index  = @forward_index
                            @forward_index  = @current_index + 1
                            @backward_index = @current_index - 1
                        end
                    end
                end

                debastardize
                nil
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
                bastardize

                @backward_index, @current_index, @forward_index = -1, 0, 1
                while @current_index < @array.size
                    item = @array.at(@current_index)
                    if yield item
                        debastardize
                        return @current_index
                    end

                    @current_index  = @forward_index
                    @forward_index  = @current_index + 1
                    @backward_index = @current_index - 1
                end

                debastardize
                nil
            end
        end
    end

    def undefine_methods ary
        ary.each do |meth|
            class << self
                begin
                    undef_method(meth)
                rescue  # Don't want to have to worry about trying to
                        # undefine a method that isn't there. This should be
                        # unnecessary once I've defined all the methods.
                end
            end
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
        class << self; undef_method(:take_progenitor_binding); end
    end
end
