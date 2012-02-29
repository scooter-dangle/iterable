class Array
    def to_iter
        IterableArray.new self
    end

    # This are super bad version. Please to fix up _so fast!_
    def swap arg1, arg2
        index1 = self.index(arg1)
        index2 = self.index(arg2)
        swap_indices index1, index2
    end

    # This are also such super bad version. Please to fix up _so fast!_
    def swap_indices arg1, arg2
        # Hooray more mess!
        # No! So sad!
        temper = at(arg1)
        self[arg1] = at(arg2) 
        self[arg2] = temper
        self
    end
end

print [:a, :b, :c].swap(:b, :c)
