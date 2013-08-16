module Iterable::Array
# module Iterators
    private
    def catch_a_break
        bastardize
        yield
    ensure
        debastardize
    end

    def increment_indices
        @current_index  = @forward_index
        @forward_index  = @current_index + 1
        @backward_index = @current_index - 1
    end

    public

    # untested and not a pretty sight in general
    # When used without a block, `#fill` is not iteration aware
    # as its default behavior is similar to that of `#replace`---
    # which is a clobberor.
    def fill *args    # obj=nil, start_or_range=nil, lengther=nil
        return @array.fill *args unless block_given?

        #######################
        # Argument processing #
        #######################
        args[0] = 0 if args.empty?

        raise ArgumentError if
            args.size > 2 or
            (args.first.kind_of? Range and args.size != 1)

        if args.first.kind_of? Range then
            args[1] = args.first.exclude_end? ?
                          args.first.last - 1 :
                          args.first.last
            args[0] = args.first.first
        end

        ##################################################
        # Translating argument array to iteration bounds #
        ##################################################
        starter = args.first
        the_final = args.at 1
        ender = lambda { the_final or length }

        #############
        # Iteration #
        #############
        catch_a_break do
            @current_index = starter
            @backward_index, @forward_index = @current_index - 1, @current_index + 1
            while @current_index < ender[]
                index_to_fill = @current_index
                self[index_to_fill] = yield @current_index
                increment_indices
            end
            self
        end
    end

    # untested
    def drop_while
        return @array.to_enum :drop_while unless block_given?

        out = Iterable::Array.new
        dropping = true
        each do |x|
            dropping = yield x if dropping
            out << x unless dropping
        end
        out
    end

    # untested
    def select
        return @array.to_enum(:select) unless block_given?
        out = Iterable::Array.new
        each { |x| out << x if yield x }
        out
    end

    # untested
    def select!
        return @array.to_enum(:select) unless block_given?
        original = @array.to_a.dup
        delete_if { |x| not yield x }
        return nil if self == original
        self
    end

    # untested
    def keep_if
        return @array.to_enum(:keep_if) unless block_given?
        delete_if { |x| not yield x }
    end

    # untested
    def count arg = :undefined
        if arg == :undefined
            return @array.length  unless block_given?
            counter = 0
            each { |x| counter += 1 if yield x }
            counter
        else
            @array.to_a.count arg
        end
    end

    def each
        return @array.to_enum(:each) unless block_given?

        catch_a_break do
            @backward_index, @current_index, @forward_index = -1, 0, 1
            while @current_index < @array.size
                yield @array.at(@current_index)
                increment_indices
            end

            self
        end
    end

    def each_index
        return @array.to_enum(:each_index) unless block_given?

        catch_a_break do
            @backward_index, @current_index, @forward_index = -1, 0, 1
            while @current_index < @array.size
                yield @current_index
                increment_indices
            end

            self
        end
    end

    def each_with_index
        return @array.to_enum(:each_with_index) unless block_given?

        catch_a_break do
            @backward_index, @current_index, @forward_index = -1, 0, 1
            while @current_index < @array.size
                yield @array.at(@current_index), @current_index
                increment_indices
            end

            self
        end
    end

    # Should delete_if be smarter / more magical than this?
    # I had considered having it test for whether an element
    # it is going to delete has already been deleted while
    # it was yielded to the iteration block. Doing so would
    # be something of a wild-goose chase but then so is this
    # entire project. I don't know if making it more 'magical'
    # would make its behavior more or less predictable to the
    # end user.
    def delete_if        # Rubinius includes `&block` as an argument, but I don't know why
        return @array.to_enum(:delete_if) unless block_given?

        catch_a_break do
            @backward_index, @current_index, @forward_index = -1, 0, 1
            while @current_index < @array.size

                # Usage of binding is necessary since this current :delete_if
                # call might be operating inside several levels of nested
                # iteration. If we just used :delete_at here, those higher
                # iteration levels would not be able to adjust their indices
                # to account for the change in array size.
                if yield @array.at(@current_index)
                    @progenitor.send :delete_at, @current_index
                end
                increment_indices
            end

            self
        end
    end

    # untested
    def reject!
        return @array.to_enum(:reject!) unless block_given?
        original = @array.to_a.dup
        delete_if { |x| yield x }
        return nil if self == original
        self
    end

    # untested
    def reject
        return @array.to_enum(:reject) unless block_given?
        out = Iterable::Array.new
        each { |x| out << x unless yield x }
        out
    end

    # untested
    # need to fix default argument to allow folks to search for nil
    def rindex obj = nil
        if obj.nil?
            return @array.to_enum(:rindex) unless block_given?

            catch_a_break do
                invert_tracking
                @current_index = @array.size - 1
                @backward_index, @forward_index = @current_index - 1, @current_index + 1
                while @current_index >= 0
                    return @current_index if yield @array.at @current_index

                    @current_index  = @backward_index
                    @forward_index  = @current_index + 1
                    @backward_index = @current_index - 1
                end
                nil
            end
        else
            @array.rindex obj
        end
    end

    def reverse_each
        return @array.to_enum(:reverse_each) unless block_given?

        catch_a_break do
            invert_tracking
            @current_index = @array.size - 1
            @backward_index, @forward_index = @current_index - 1, @current_index + 1
            while @current_index >= 0
                yield @array.at @current_index

                @current_index  = @backward_index
                @forward_index  = @current_index + 1
                @backward_index = @current_index - 1
            end

            self
        end
    end

    # untested
    def take_while
        return @array.to_enum(:take_while) unless block_given?
        out = Iterable::Array.new
        each { |x| break unless yield x; out << x }
        out
    end

    def map
        return @array.dup unless block_given?
        out = Iterable::Array.new

        catch_a_break do
            @backward_index, @current_index, @forward_index = -1, 0, 1
            while @current_index < @array.size
                out << yield(@array.at @current_index)
                increment_indices
            end

            out
        end
    end

    alias_method :collect, :map

    def map!
        return to_enum(:map!) unless block_given?

        catch_a_break do
            @backward_index, @current_index, @forward_index = -1, 0, 1
            while @current_index < @array.size
                # The following verbosity required so that @current_index will be
                # evaluated after any modifications to it by the block.
                temp_value = yield(@array.at @current_index)
                @array[@current_index] = temp_value
                increment_indices
            end

            self
        end
    end

    alias_method :collect!, :map!

    def cycle n = nil, &block
        return @array.to_enum(:cycle, n) unless block_given?

        catch_a_break do
            cycle_conditional_helper n do
                @backward_index, @current_index, @forward_index = -1, 0, 1
                while @current_index < @array.size
                    yield @array.at(@current_index)
                    increment_indices
                end
            end

            nil
        end
    end

    def cycle_conditional_helper n, &block
        n.nil? ?
            (yield until @array.empty?) :
            n.times { yield }
    end
    private :cycle_conditional_helper

    def index obj = :undefined
        unless block_given?
            # What should I change :undefined to?
            # I can't use null or nil or anything in case the index
            # of null or nil needs to be looked up.
            # Rubinius uses a plain (non-symbol) 'undefined' keyword,
            # but that doesn't seem to work in 1.9.2.
            return @array.index(obj) unless obj == :undefined
            return @array.to_enum(:index)
        end

        catch_a_break do
            @backward_index, @current_index, @forward_index = -1, 0, 1
            while @current_index < @array.size
                return @current_index if yield @array.at(@current_index)
                increment_indices
            end

            nil
        end
    end

    # Have not tested aliased iterators to ensure
    # maximal efficacitic beneficial results
    alias_method :find_index, :index

    # untested
    def zip *args
        if block_given?
            i = 0
            each do |x|
                out = [x]
                args.each { |arg| out.push arg.at i }
                i += 1
                yield self.class.new out
            end
            nil
        else
            self.class.new(to_a.zip(*args).map { |x| self.class.new x })
        end
    end

    # untested
    def product *arrays
        return Iterable::Array.new @array.product(*arrays) unless block_given?

        each do |x|
            basket = [x].product *arrays
            # means of skipping a whole chunk of yields
            catch :product_next do
                basket.each { |y| yield Iterable::Array.new y }
            end
        end
    end

    # Currently only defined for arrays `a` where `a.uniq == a`
    def permutation n = @array.size, &block
        comb_perm_helper :permutation, n, &block
    end

    # Currently only defined for arrays `a` where `a.uniq == a`
    def combination n, &block
        comb_perm_helper :combination, n, &block
    end

    # Currently only defined for arrays `a` where `a.uniq == a`
    def repeated_permutation n = @array.size, &block
        comb_perm_helper :repeated_permutation, n, &block
    end

    # Currently only defined for arrays `a` where `a.uniq == a`
    def repeated_combination n, &block
        comb_perm_helper :repeated_combination, n, &block
    end

    private
    def comb_perm_helper methd, n
        return @array.to_enum(methd, n) unless block_given?
        @backward_index, @current_index, @forward_index = 0, 0, 0

        catch_a_break do
            queue = comb_perm_generator methd, to_a, n
            history = []
            until queue.empty?
                element = queue.shift
                previous = to_a.sort
                yield element
                history.push element
                queue = diff_handler queue, history, previous, methd, n unless to_a.sort == previous
            end
            self
        end
    end

    def comb_perm_generator methd, ary, n
        out = []
        ary.send(methd, n) { |item| out << item }
        out
    end

    # only for :permutation/:combination and their cousins
    def diff_handler queue, history, previous, methd, n
        deleted_items = previous - self
        new_items = self - previous
        queue = remove_deleted_items queue, deleted_items
        queue = add_new_items queue, history, new_items, methd, n
        queue
    end

    # only for :permutation/:combination and their cousins
    def add_new_items queue, history, items, methd, n
        new_elements = comb_perm_generator methd, to_a, n
        new_elements -= history
        queue += new_elements
        queue
    end

    # only for :permutation/:combination and their cousins
    def remove_deleted_items queue, items
        items.each do |item|
            queue.delete_if { |x| x.include? item }
        end
        queue
    end
# end
end
