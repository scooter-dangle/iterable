module Swapable
    def to_iter
        IterableArray.new self
    end

    def to_a
        self
    end

    def swap_2_indices! arg1, arg2
        temper = at arg1
        self[arg1] = at arg2
        self[arg2] = temper
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
        dup.extend(Swapable).swap! *args
    end

    def swap_indices *args
        dup.extend(Swapable).swap_indices! *args
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
