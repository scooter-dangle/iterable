module Iterable::Array
# module SpecialAccessors
    def [](arg1, arg2=nil)
        case arg1
        when Fixnum
            return super unless arg2
            super.to_iter!
        when Range
            super(arg1).to_iter!
        end
    end

    alias_method :slice, :[]

    # @return [Iterable::Array]
    def drop n
        super.to_iter!
    end

    # @return [Iterable::Array]
    # untested
    def dup
        super.to_iter!
    end

    # @return [Iterable::Array]
    def first n = nil
        return super if n == nil
        super.to_iter!
    end

    # @return [Iterable::Array]
    def last n = nil
        return super if n == nil
        super.to_iter!
    end

    # @return [Iterable::Array]
    # untested
    def compact
        super.to_iter!
    end

    # Not defined since Array#nitems is not defined in 1.9.2+
    # def nitems
    # end

    # @return [Iterable::Array]
    def & arg
        super.to_iter!
    end

    # @return [Iterable::Array]
    def | arg
        super.to_iter!
    end

    # @return [Iterable::Array]
    def + arg
        super.to_iter!
    end

    # @return [Iterable::Array]
    def - arg
        super.to_iter!
    end

    # @return [Iterable::Array]
    def * arg
        return super.to_iter! if arg.kind_of? Fixnum
        super
    end

    # @return [Iterable::Array]
    def values_at *args
        super.to_iter!
    end

    alias_method :indices, :values_at
    alias_method :indexes, :values_at

    # TODO need Mspec test...ran into problems with this one
    def sample arg = nil
        return super.to_iter! unless arg.nil?
        super
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
        super.to_iter!
    end

    # untested
    def reverse
        super.to_iter!
    end

    # untested
    def rotate n = 1
        super.to_iter!
    end

    def sort
        super.to_iter!
    end

    def shuffle
        super.to_iter!
    end

    def swap *args
        super.to_iter!
    end

    def swap_indices *args
        super.to_iter!
    end

    # untested
    def take n
        super.to_iter!
    end

    # untested
    # Note: All internal arrays will also be Iterable::Arrays.
    # Any point at all to this? One doubts...
    def transpose
        # So. Pointless. Blerg.
        super.each(&:to_iter!).to_iter!
    end

    # untested
    def uniq
        super.to_iter!
    end
# end
end
