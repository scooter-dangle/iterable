class Array
    def to_iter
        Iterable::Array.new self
    end
end
