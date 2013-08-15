module Iterable
    module Array
    # module SpecialAccessors
        def << arg
            @array << arg
            self
        end

        # @return [Iterable::Array]
        def concat arg
            arg.each { |x| @array << x }
            self
        end

        def [](arg1, arg2=nil)
            case arg1

            when Fixnum
                return @array.at(arg1) unless arg2

                Iterable::Array.new @array[arg1, arg2]

            when Range
                Iterable::Array.new @array[arg1]
            end
        end

        alias_method :slice, :[]

        # @return [Iterable::Array]
        def drop n
            Iterable::Array.new @array.drop n
        end

        # @return [Iterable::Array]
        # untested
        def dup
            Iterable::Array.new @array.to_a.dup
        end

        # @return [Iterable::Array]
        def first n = nil
            return @array.first if n == nil
            Iterable::Array.new @array.first(n)
        end

        # @return [Iterable::Array]
        def last n = nil
            return @array.last if n == nil
            Iterable::Array.new @array.last(n)
        end

        # @return [Iterable::Array]
        def push *args
            @array.push *args
            self
        end

        # @return [Iterable::Array]
        # untested
        def compact
            Iterable::Array.new @array.compact
        end

        # It looks like Array#assoc and Array#rassoc return
        # Array versions of their elements when they find a
        # match. I'm not sure why that is... You'd think it
        # would be more duck-typish to maintain the object's
        # class, right? I dunno why it has to be so sad.
        def assoc obj
            @array.each do |x|
                if x.respond_to? :at and x.at(0) == obj
                    return x
                end
            end

            nil
        end

        # See note above assoc.
        def rassoc obj
            @array.each do |elem|
                if elem.respond_to? :at and elem.at(1) == obj
                    return elem
                end
            end

            nil
        end

        # Not defined since Array#nitems is not defined in 1.9.2+
        # def nitems
        # end

        # @return [Iterable::Array]
        def & arg
            Iterable::Array.new(@array & arg.to_a)
        end

        # @return [Iterable::Array]
        def | arg
            Iterable::Array.new(@array | arg.to_a)
        end

        # @return [Iterable::Array]
        def + arg
            Iterable::Array.new(@array + arg)
        end

        # @return [Iterable::Array]
        def - arg
            Iterable::Array.new(@array - arg)
        end

        # @return [Iterable::Array]
        def * arg
            return Iterable::Array.new @array * arg if arg.kind_of? Fixnum
            @array * arg
        end

        # @return [Integer]
        def <=>(other)
            return @array <=> other.to_a if other.kind_of? Iterable::Array
            @array <=> other
        end

        # @return [Iterable::Array]
        def values_at *args
            out = Iterable::Array.new
            args.each do |arg|
                out += @array.values_at arg
            end
            out
        end

        alias_method :indices, :values_at
        alias_method :indexes, :values_at

        # TODO need Mspec test...ran into problems with this one
        def sample arg = nil
            return Iterable::Array.new(@array.sample arg) unless arg.nil?
            @array.sample
        end

        # :eql? returns true only when array contents are the same and
        # both objects are Iterable::Array instances
        # @return [Boolean]
        def eql? arg
            (arg.class == Iterable::Array) and
                (self == arg.to_a)
        end

        # untested
        # @return [Iterable::Array] sub arrays flattened as in Array#flatten
        def flatten level = -1
            Iterable::Array.new @array.flatten(level)
        end

        # untested
        def reverse
            Iterable::Array.new @array.reverse
        end

        # untested
        def rotate n = 1
            Iterable::Array.new @array.rotate(n)
        end

        # untested
        def replace *args
            @array.replace *args
            self
        end

        def sort
            Iterable::Array.new @array.sort
        end

        def shuffle
            Iterable::Array.new @array.shuffle
        end

        def swap *args
            Iterable::Array.new @array.swap(*args)
        end

        def swap_indices *args
            Iterable::Array.new @array.swap_indices(*args)
        end

        # untested
        def take n
            Iterable::Array.new @array.take(n)
        end

        # untested
        # Note: All internal arrays will also be Iterable::Arrays.
        # Any point at all to this? One doubts...
        def transpose
            # So. Pointless. Blerg.
            Iterable::Array.new(@array.transpose.map do |x|
                Iterable::Array.new x
            end)
        end

        # untested
        def uniq
            Iterable::Array.new @array.uniq
        end
    # end
    end
end
