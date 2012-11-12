class IterableArray
    # module SpecialModifiersIterating
    private
    def define_special_modifiers_iterating
        class << self
            def clear
                @backward_index -= @current_index
                @forward_index  -= @current_index
                @current_index   = 0
                @array.clear
            end

            # untested
            def compact!
                delete_if &:nil?
                self
            end

            def shift n = nil
                return self.delete_at(0) if n == nil

                out = IterableArray.new
                [ n, @array.length ].min.times { out << self.delete_at(0) }
                out
            end

            def insert location, *items
                location = size + location if location < 0

                @array.insert location, *items  # I put this here rather than at the end
                                                # so that any possible location error is raised
                                                # before modifying the indices.

                center_indices_at(@current_index + items.size) if location <= @current_index

                self
            end

            # untested
            def move element, to
                from = index element
                move_from from, to
            end

            # untested
            def move_from from, to
                if from == @current_index then
                    center_indices_at to
                elsif from < @current_index and to >= @current_index
                    center_indices_at(@current_index - 1)
                elsif from > @current_index and to <= @current_index
                    center_indices_at(@current_index + 1)
                end
                @array.move_from from, to
            end

            # untested
            def flatten! level = -1
                return self if level.zero?
                @forward_index = to_a[0...@forward_index].flatten(level).size
                @backward_index = @forward_index - 1
                @current_index = (@backward_index + @tracking.abs + @tracking).to_int
                @array.flatten! level
                self
            end

            def slice! start, length=:undefined
                if length.equal? :undefined
                    if start.kind_of? Range
                        out = IterableArray.new @array.slice(start)
                        first, last = start.first, start.last
                        first += @array.length if first < 0
                        last  += @array.length if last  < 0
                        if first <= last
                            length = last - first
                            length += 1 unless start.exclude_end?
                            length.times { delete_at first }
                        end
                    else
                        out = delete_at start
                    end
                else
                    out = IterableArray.new @array.slice(start, length)
                    start += @array.length if start < 0
                    length.times { delete_at start }
                end
                out
            end

            def unshift *args
                insert 0, *args
                self
            end

            def pop n = nil
                return delete_at(size - 1) if n.nil?

                out = IterableArray.new []
                n.times { out.unshift pop }
                out
            end

            def reverse!
                @backward_index, @forward_index =
                    @array.size - 1 - @forward_index,
                    @array.size - 1 - @backward_index

                # @current_index = @backward_index  + 1
                @current_index = @array.size - 1 - @current_index

                @current_index = case @current_index
                                 when @backward_index then @forward_index
                                 when @forward_index  then @backward_index
                                                      else @current_index
                                 end

                invert_tracking

                @array.reverse!
                self
            end

            # partially tested (not tested nested)
            def rotate! n = 1
                n %= size
                return self if n.zero?
                new_index = (@current_index - n) % size
                center_indices_at new_index
                @array.rotate! n
            end

            # Still need to implement with block
            # `#sort!` modification is iterative-aware, but the instance
            # of IterableArray should not be modified from within a `#sort!`
            # block:
            #   quoth the pickaxe: _arr_ is effectively frozen while a sort is in progress
            def sort!
                return @array.sort! unless @current_index.between? 0, @array.size.pred

                current_item = @array.at @current_index
                offset = @array.to_a[0...@current_index].count current_item

                @array.sort!

                center_indices_at (@array.to_a.index(current_item) + offset)

                self
            end

            # untested
            # `#sort_by!` modification is iterative-aware, but the instance
            # of IterableArray should not be modified from within a `#sort_by!`
            # block:
            #   quoth the pickaxe: _arr_ is effectively frozen while a sort is in progress
            def sort_by! &block
                return @array.to_enum(:sort_by!) unless block_given?

                current_item = @array.at @current_index
                offset = @array.to_a[0...@current_index].count current_item

                @array.sort_by! &block

                center_indices_at (@array.to_a.index(current_item) + offset)

                self
            end

            def shuffle!
                return @array.shuffle! unless @current_index.between? 0, @array.size.pred

                current_item = @array.at @current_index
                count = @array.to_a.count current_item

                @array.shuffle!

                locations = []
                @array.to_a.each_with_index { |item, location| locations << location if item == current_item }

                center_indices_at locations.sample

                self
            end

            def swap! *args
                args.map! { |x| index x }
                swap_indices! *args
            end

            def swap_indices! *args
                args.inject { |i1, i2| swap_2_indices!(i1, i2); i2 }
                self
            end
            alias_method :swap_indexes!, :swap_indices!

            # untested
            def uniq!
                basket = []
                delete_if do |x|
                    if basket.include? x
                        true
                    else
                        basket << x
                        false
                    end
                end
                self
            end

            protected
            def swap_2_indices! arg1, arg2
                temp_holder = @current_index
                center_indices_at arg1 if temp_holder == arg2
                center_indices_at arg2 if temp_holder == arg1
                @array.swap_indices! arg1, arg2
            end

            private
            def center_indices_at new_index
                movement = @current_index - new_index
                @current_index  -= movement
                @forward_index  -= movement
                @backward_index -= movement
            end
        end
    end
end
