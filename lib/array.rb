class Array
    def to_iter
        IterableArray.new self
    end
end
