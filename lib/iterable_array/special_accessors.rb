class IterableArray
    # module SpecialAccessors
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

        def push *args
            @array.push *args
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

        # TODO need Mspec test...ran into problems with this one
        def sample arg = nil
            return IterableArray.new(@array.sample arg) unless arg.nil?
            @array.sample
        end

        # :eql? returns true only when array contents are the same and
        # both objects are IterableArray instances
        def eql? arg
            (arg.class == IterableArray) and
                (self == arg.to_a)
        end

        # untested
        def flatten level = -1
            IterableArray.new @array.flatten(level)
        end

        # untested
        def reverse
            IterableArray.new @array.reverse
        end

        # untested
        def rotate n = 1
            IterableArray.new @array.rotate(n)
        end

        # untested
        def replace *args
            @array.replace *args
            self
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
        # Note: All internal arrays will also be IterableArrays.
        # Any point at all to this? One doubts...
        def transpose
            # So. Pointless. Blerg.
            IterableArray.new(@array.transpose.map do |x|
                IterableArray.new x
            end)
        end

        # untested
        def uniq
            IterableArray.new @array.uniq
        end
    # end
end
