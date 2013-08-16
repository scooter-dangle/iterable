module Swapable
    def self.new *args
        Array.new(*args).extend self
    end

    def to_a
        self
    end

    def dup
        (super).extend Swapable
    end

    # A version of Array#- that's friendlier to method-chaining
    def less *elements
        (self - elements).extend Swapable
    end

    def swap_2_indices! i1, i2
        self[i1], self[i2] = self[i2], self[i1]
        self
    end
    protected :swap_2_indices!

    def swap! *args
        args.map! { |x| index x }
        swap_indices! *args
    end

    def swap_indices! *args
        args.inject { |i1, i2| swap_2_indices! i1, i2; i2 }
        self
    end
    alias_method :swap_indexes!, :swap_indices!

    def swap *args
        dup.swap! *args
    end

    def swap_indices *args
        dup.swap_indices! *args
    end
    alias_method :swap_indexes, :swap_indices

    def move_from from, to
        element = delete_at from
        insert to, element
    end

    def move element, to
        delete_at index element
        insert to, element
    end
end
