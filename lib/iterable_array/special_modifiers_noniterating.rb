class IterableArray
    module SpecialModifiersNoniterating
        # untested
        def compact!
            @array.compact!
            self
        end

        def clear
            @array.clear
            self
        end

        def shift n = nil
            return @array.shift if n.nil?
            IterableArray.new @array.shift(n)
        end

        def insert location, *items
            @array.insert location, *items
            self
        end

        # untested
        def move element, to
            @array.move element, to
            self
        end

        # untested
        def move_from from, to
            @array.move_from from, to
            self
        end

        # untested
        def flatten! level = -1
            @array.flatten! level
            self
        end

        def pop n = nil
            return @array.pop if n.nil?
            IterableArray.new(@array.pop n)
        end

        def reverse!
            @array.reverse!
            self
        end

        # untested
        def rotate! n = 1
            @array.rotate! n
            self
        end

        def sort!
            @array.sort!
            self
        end

        # untested
        def sort_by! &block
            return @array.to_enum(:sort_by!) unless block_given?
            @array.sort_by! &block
            self
        end

        def shuffle!
            @array.shuffle!
            self
        end

        def slice! *args
            if args.length == 2 or args.at(1).kind_of? Range
                IterableArray.new @array.slice!(*args)
            else
                @array.slice!(*args)
            end
        end

        def unshift *args
            @array.insert 0, *args
            self
        end

        def swap! *args
            @array.swap! *args
            self
        end

        def swap_indices! *args
            @array.swap_indices! *args
            self
        end

        # untested
        def uniq!
            @array.uniq!
            self
        end
    end
end
