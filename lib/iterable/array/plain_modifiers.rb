class Iterable
    class Array
        # module PlainModifiers
        private
        def define_plain_modifiers
            class << self
                def delete_at location
                    # Flip to positive and weed out out of bounds
                    location += @array.size if location < 0
                    return nil unless location.between? 0, @array.size.pred

                    @forward_index  -= 1 if location < @forward_index
                    @current_index  -= 1 if location < @current_index - @tracking
                    @backward_index -= 1 if location < @backward_index

                    @array.delete_at location
                end

                # currently untested
                def delete obj
                    n = count obj
                    if n.zero?
                        return yield obj if block_given?
                        nil
                    else
                        n.times { delete_at index obj }
                        obj
                    end
                end
            end
        end
    end
end
