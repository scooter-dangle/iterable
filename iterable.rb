require 'forwardable'

class IterableArray
    extend Forwardable

    # attr_accessor :array  # For testing purposes only!
    
    # @@plain_accessors contains methods that return a non-array without
    # modifying the called array.

    @@plain_accessors = [ :==, :size, :length, :to_a, :to_s, :include?, :hash, :to_ary, :inspect, :at, :reverse, :empty? ]

    # @@special_accessors contains non-modifying methods that (would otherwise)
    # return an array. For this class, we want to return IterableArray objects
    # instead. Note: A few methods can still return a non-array in some cases.
    #
    # Description above is outdated. Should probably rename @@special_accessors
    # as @@complex_accessors. (Since many of them have to be handled
    # specially for reasons other than that they return an array.)

    @@special_accessors = [ :&, :*, :+, :-, :<<, :[], :eql?, :indices, :indexes, :values_at, :join, :assoc, :rassoc, :first, :last ]

    @@modifiers = [ :delete, :delete_at, :pop, :push ]
    @@iterators = [ :each, :collect, :collect!, :map, :map!, :combination, :count, :cycle, :delete_if, :drop_while, :each_index, :select ]

    # @@hybrids contains methods that fit into the previous groups depending
    # on the arguments passed.

    @@hybrids   = [ :fetch, :fill, :index ]

    # The following two lines are supposed to help me keep track of progress.
    # working:  Array#public_instance_methods => [ :frozen?, :[]=, :concat, :<<, :shift, :unshift, :insert, :reverse_each, :find_index, :rindex, :reverse!, :rotate, :rotate!, :sort, :sort!, :sort_by!, :select!, :keep_if, :delete_if, :reject, :reject!, :zip, :transpose, :replace, :clear, :<=>, :slice, :slice!, :|, :uniq, :uniq!, :compact, :compact!, :flatten, :flatten!, :shuffle!, :shuffle, :sample, :cycle, :permutation, :repeated_permutation, :repeated_combination, :product, :take, :take_while, :drop, :pack, :entries, :sort_by, :grep, :find, :detect, :find_all, :flat_map, :collect_concat, :inject, :reduce, :partition, :group_by, :all?, :any?, :one?, :none?, :min, :max, :minmax, :min_by, :max_by, :minmax_by, :member?, :each_with_index, :each_entry, :each_slice, :each_cons, :each_with_object, :chunk, :slice_before, :nil?, :===, :=~, :!~, :clone, :dup, :freeze, :tap, :extend, :display, :to_enum, :enum_for, :!, :!= ]
    # original: Array#public_instance_methods => [ :inspect, :to_s, :to_a, :to_ary, :frozen?, :==, :eql?, :hash, :[], :[]=, :at, :fetch, :first, :last, :concat, :<<, :push, :pop, :shift, :unshift, :insert, :each, :each_index, :reverse_each, :length, :size, :empty?, :find_index, :index, :rindex, :join, :reverse, :reverse!, :rotate, :rotate!, :sort, :sort!, :sort_by!, :collect, :collect!, :map, :map!, :select, :select!, :keep_if, :values_at, :delete, :delete_at, :delete_if, :reject, :reject!, :zip, :transpose, :replace, :clear, :fill, :include?, :<=>, :slice, :slice!, :assoc, :rassoc, :+, :*, :-, :&, :|, :uniq, :uniq!, :compact, :compact!, :flatten, :flatten!, :count, :shuffle!, :shuffle, :sample, :cycle, :permutation, :combination, :repeated_permutation, :repeated_combination, :product, :take, :take_while, :drop, :drop_while, :pack, :entries, :sort_by, :grep, :find, :detect, :find_all, :flat_map, :collect_concat, :inject, :reduce, :partition, :group_by, :all?, :any?, :one?, :none?, :min, :max, :minmax, :min_by, :max_by, :minmax_by, :member?, :each_with_index, :each_entry, :each_slice, :each_cons, :each_with_object, :chunk, :slice_before, :nil?, :===, :=~, :!~, :class, :singleton_class, :clone, :dup, :initialize_dup, :initialize_clone, :taint, :tainted?, :untaint, :untrust, :untrusted?, :trust, :freeze, :methods, :singleton_methods, :protected_methods, :private_methods, :public_methods, :instance_variables, :instance_variable_get, :instance_variable_set, :instance_variable_defined?, :instance_of?, :kind_of?, :is_a?, :tap, :send, :public_send, :respond_to?, :respond_to_missing?, :extend, :display, :method, :public_method, :define_singleton_method, :__id__, :object_id, :to_enum, :enum_for, :equal?, :!, :!=, :instance_eval, :instance_exec, :__send__ ]

    # The following 2 lines don't work in 1.8.7/1.9.2... I need to look up using
    # arrays as args for those?
    # def_delegators :@array, @@plain_accessors
    # def_delegators :@array, @@modifiers
    #
    # Using the following instead:

    @@plain_accessors.each { |meth| def_delegator :@array, meth }
    @@modifiers.each { |meth| def_delegator :@array, meth }


    def initialize( array = [] )
        @array = Array.new array
        define_iterators
        define_special_accessors
    end

    private # Only comment out for testing purposes.

    def bastardize
        @array = IterableArray.new @array
        undefine_methods @@special_accessors
        undefine_methods @@iterators
        class << self
            @@special_accessors.each { |meth| def_delegator :@array, meth }
            # def_delegators :@array, @@iterators
            @@iterators.each { |meth| def_delegator :@array, meth }
        end
        define_modifiers
    end

    def debastardize
        @array = @array.to_a
        undefine_methods @@modifiers
        class << self
            # def_delegators :@array, @@modifiers
            @@modifiers.each { |meth| def_delegator :@array, meth }
        end
        define_special_accessors
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

            def first(n = nil)
                return @array.first if n == nil
                IterableArray.new @array.first(n)
            end

            def last(n = nil)
                return @array.last if n == nil
                IterableArray.new @array.last(n)
            end

            def assoc(obj)
                each do |x|
                    if x.respond_to? :at and x.at(0) == obj
                        return x
                    end
                end

                nil
            end

            def rassoc(obj)
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

            def values_at(*args)
                out = []
                args.each do |arg|
                    out += @array.values_at(arg)
                end
                IterableArray.new out
            end

            alias_method :indices, :values_at
            alias_method :indexes, :values_at

            def <<(arg)
                @array << arg
                self
            end

            # :join is defined here (instead of directly delegating it to
            # @array) since we might want to later define how it handles
            # an array that contains IterableArrays as elements.
            def join(sep=nil)
                @array.join(sep)
            end

            # :eql? returns true only when array contents are the same and
            # both objects are IterableArray instances
            def eql?(arg)
                (arg.class == IterableArray) and
                    (self == arg.to_a)
            end
        end
    end

    def define_modifiers
        class << self
            def pop
                puts ":pop called on bastardized array"
            end

            def push (value)
                puts ":push called on bastardized array"
            end

            def delete_at (index)
                puts ":delete_at called on bastardized array"
            end
        end
    end

    def define_iterators
        class << self
            def each
                return @array.to_enum(:each) unless block_given?

                bastardize

                @iter_index = 0
                while @iter_index < @array.size
                    yield @array.at(@iter_index)
                    @iter_index += 1
                end

                debastardize
            end

            def collect
            end
        end
    end

    def undefine_methods(ary)
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
#    def method_missing( method, *args, &block )
#        @array.send( method, *args, &block )
#    end
end
