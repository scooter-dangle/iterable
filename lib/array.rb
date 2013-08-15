class Array
    def to_iter
        Iterable::Array.new self
    end

    def to_iter!
        extend Iterable::Array
    end
end
