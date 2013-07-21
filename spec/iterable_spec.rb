require "#{File.expand_path File.dirname __FILE__}/../lib/iterable"
require "#{File.expand_path File.dirname __FILE__}/spec_helper"

describe IterableArray do
    it 'does not claim to be an Array' do
        @iter_ary = IterableArray.new
        @iter_ary.class.should_not == Array
        @iter_ary.class.should == IterableArray
    end

    it 'responds to every Array instance method' do # MAYbe...
        @iter_ary = IterableArray.new
        mthds = Array.instance_methods(false)
        # Remove JRuby specific methods
        jruby = ['iter_for_each', 'iter_for_each_index', 'iter_for_each_with_index', 'iter_for_reverse_each', 'copy_data_simple']
        jruby += jruby.map &:to_sym
        jruby.each { |method| mthds.delete method }
        # Remove Rubinius-specific methods
        rbx = ['total', 'total=', 'to_generator', 'to_tuple', 'tuple', 'tuple=', 'start', 'start=', 'sort_inplace', 'new_range', 'new_reserved', '__append__', '__marshal__', '__matches_when__', '__rescue_match__']
        rbx += rbx.map &:to_sym
        rbx.each { |method| mthds.delete method }

        mthds.each do |method|
            @iter_ary.should respond_to(method)
        end

        @iter_ary = IterableArray.new [1]
        @iter_ary.each do
            mthds.each do |method|
                @iter_ary.should respond_to(method)
            end
        end
    end

    it 'responds to every Enumerable instance method' do # MAYbe...
        @iter_ary = IterableArray.new
        Enumerable.instance_methods(false).each do |method|
            @iter_ary.should respond_to(method)
        end

        @iter_ary = IterableArray.new [1]
        @iter_ary.each do
            Enumerable.instance_methods(false).each do |method|
                @iter_ary.should respond_to(method)
            end
        end
    end

    describe ':assoc and :rassoc' do
        # This test are super stupid. No point for it. Please
        # to get rid of so fast. Mebbeh.
        it 'work like Array#assoc and Array#rassoc but return IterableArrays' do
            @ary = [42, ['x', 'y', 'z'], [0, 1, 2], IterableArray.new( [:alpha, :beta, :gamma] )]
            @iter_ary = IterableArray.new @ary

            @iter_ary.assoc(0).should == @ary.assoc(0)
            @iter_ary.assoc(1).should == @ary.assoc(1)
            @iter_ary.assoc(:alpha).should == [:alpha, :beta, :gamma]
            @iter_ary.assoc(:beta).should == nil

            @iter_ary.rassoc(0).should == @ary.rassoc(0)
            @iter_ary.rassoc(1).should == @ary.rassoc(1)
            @iter_ary.rassoc(:alpha).should == nil
            @iter_ary.rassoc(:beta).should == [:alpha, :beta, :gamma]
        end
    end

    # Testing :== might be overkill, but I want to be safe since rspec uses it
    # every time I do "___.should == ___"
    describe ':==' do
        it 'returns false for differing array content' do
            @ary_1 = [0, 1, 2]
            @iter_ary_1 = IterableArray.new ['a', 'b', 'c']
            ( @iter_ary_1 == @ary_1 ).should be_false
            ( @ary_1 == @iter_ary_1 ).should be_false
        end

        it 'returns true if array content matches but classes differ' do
            @ary_1 = [0, 1, 2]
            @iter_ary_1 = IterableArray.new @ary_1
            ( @iter_ary_1 == @ary_1 ).should be_true
            ( @ary_1 == @iter_ary_1 ).should be_true
        end
    end


    it ':eql? acts like a class-sensitive version of :==' do
        @ary_1 = [0, 1, 2]
        @ary_2 = ['a', 'b', 'c']
        @iter_ary_1 = IterableArray.new @ary_1
        @iter_ary_2 = IterableArray.new @ary_1
        @iter_ary_3 = IterableArray.new @ary_2
        @iter_ary_1.eql?(@ary_1).should be_false
        @iter_ary_1.eql?(@iter_ary_2).should be_true
        @iter_ary_1.eql?(@iter_ary_3).should be_false
    end


    describe 'instance methods' do
        it 'return an IterableArray when the corresponding Array method would return an array' do
            @iter_ary = IterableArray.new ['a', 'b', 'c', 'd']
            @ary = [0, 1, 2, 3]
            num   = 3
            ( @iter_ary & @ary )        .should be_an_instance_of(IterableArray)
            ( @iter_ary + @ary )        .should be_an_instance_of(IterableArray)
            ( @iter_ary - @ary )        .should be_an_instance_of(IterableArray)
            ( @iter_ary | @ary )        .should be_an_instance_of(IterableArray)
            ( @iter_ary * num  )        .should be_an_instance_of(IterableArray)
            @iter_ary.sort              .should be_an_instance_of(IterableArray)
            ( @iter_ary << num )        .should be_an_instance_of(IterableArray)
            @iter_ary.concat([num])     .should be_an_instance_of(IterableArray)
            @iter_ary[1, 2]             .should be_an_instance_of(IterableArray)
            @iter_ary[1...num]          .should be_an_instance_of(IterableArray)
            @iter_ary.slice(1, 2)       .should be_an_instance_of(IterableArray)
            @iter_ary.slice(1...num)    .should be_an_instance_of(IterableArray)
            @iter_ary.values_at(1...num).should be_an_instance_of(IterableArray)
            @iter_ary.values_at(0)      .should be_an_instance_of(IterableArray)
            @iter_ary.values_at(1, 0)   .should be_an_instance_of(IterableArray)
            @iter_ary.indices((1..2))   .should be_an_instance_of(IterableArray)
            @iter_ary.indexes((1..2))   .should be_an_instance_of(IterableArray)
            @iter_ary.first(3)          .should be_an_instance_of(IterableArray)
            @iter_ary.last(3)           .should be_an_instance_of(IterableArray)
            @iter_ary.shuffle           .should be_an_instance_of(IterableArray)
            @iter_ary.drop(3)           .should be_an_instance_of(IterableArray)
            @iter_ary.push(num)         .should be_an_instance_of(IterableArray)
            @iter_ary.unshift(num)      .should be_an_instance_of(IterableArray)
        end

        it 'return an IterableArray when the corresponding Array method would return an array', :method => :sample do
            @iter_ary = IterableArray.new ['a', 'b', 'c', 'd']
            @iter_ary.sample(3)         .should be_an_instance_of(IterableArray)
        end

        it "that don't iterate work the same as array methods outside of iteration blocks" do
            @ary = ['a', 'b', 'c', 'd']
            @iter_ary = IterableArray.new @ary
            @ary_2 = ['c', 'd', 'e']
            @iter_ary_2 = IterableArray.new @ary_2
            num = 3

            # :sort
            @iter_ary.shuffle.sort.should == @ary.shuffle.sort

            # :<<
            ( @iter_ary << num ).should == ( @ary << num )

            # :concat
            ( @iter_ary.concat [num] ).should == ( @ary.concat [num] )

            # :<=>
            ( @iter_ary <=> @iter_ary_2 ).should == ( @ary <=> @ary_2 )
            ( @iter_ary_2 <=> @iter_ary ).should == ( @ary_2 <=> @ary )
            ( @iter_ary <=> @iter_ary ).should == ( @ary <=> @ary )

            # :&
            ( @iter_ary_2 & @ary ).should == ( @ary_2 & @ary )

            # :|
            ( @iter_ary_2 | @ary ).should == ( @ary_2 | @ary )

            # :+
            ( @iter_ary + @ary ).should == ( @ary + @ary )

            # :-
            ( @iter_ary_2 - @ary ).should == ( @ary_2 - @ary )

            # :+
            ( @iter_ary + @ary ).should == ( @ary + @ary )

            # :[]
            @iter_ary[num].should == @ary[num]
            @iter_ary[1...num].should == @ary[1...num]
            @iter_ary[1, num].should == @ary[1, num]

            # :values_at
            @iter_ary.values_at(num).should == @ary.values_at(num)
            @iter_ary.values_at(1...num).should == @ary.values_at(1...num)
            @iter_ary.values_at(1, num, 0, 0..num).should == @ary.values_at(1, num, 0, 0..num)

            # :*
            (@iter_ary * ' ').should == (@ary * ' ')
            (@iter_ary * 2).should == (@ary * 2)

            # :first
            @iter_ary.first.should == @ary.first
            @iter_ary.first(2).should == @ary.first(2)

            # :last
            @iter_ary.last.should == @ary.last
            @iter_ary.last(2).should == @ary.last(2)

            # :join
            # Need to determine how to handle the case where an
            # IterableArray contains further IterableArrays. This
            # also applies to :transpose.
            @iter_ary.join(' ').should == @ary.join(' ')
            @iter_ary.join.should == @ary.join

            # :index
            obj = 'b'
            @iter_ary.index(obj).should == @ary.index(obj)
            obj = 'z'
            @iter_ary.index(obj).should == @ary.index(obj)

            # :drop
            @iter_ary.drop(num).should == @ary.drop(num)

            # :unshift
            @iter_ary.unshift(num).should == @ary.unshift(num)
            @iter_ary.unshift(4, 6, 84).should == @ary.unshift(4, 6, 84)

            # :push
            @iter_ary.push(num).should == @ary.push(num)
            @iter_ary.should == @ary

            # :insert
            @iter_ary.insert(1, num, 'b').should == @ary.insert(1, num, 'b')
            @iter_ary.should == @ary
            @iter_ary.insert(-1, 8).should == @ary.insert(-1, 8)
            @iter_ary.should == @ary
            @iter_ary.insert(21, 8).should == @ary.insert(21, 8)
            @iter_ary.should == @ary

            # :shuffle
            array_1, array_2 = [], []
            6.times { array_1 << @iter_ary.shuffle }
            6.times { array_2 <<      @ary.shuffle }
            array_1.should_not == array_2
        end

        it "that don't iterate work the same as array methods outside of iteration blocks", :method => :sample do
            @ary = ['a', 'b', 'c', 'd']
            @iter_ary = IterableArray.new @ary

            array_1, array_2 = [], []
            10.times { array_1 << @iter_ary.sample(2) }
            10.times { array_2 <<      @ary.sample(2) }
            array_1.should_not == array_2

            @iter_ary.sample(1_000).size.should == @ary.sample(1_000).size
        end

        it "that don't iterate work the same as array methods outside of iteration blocks", :method => :choice do
            @ary = ['a', 'b', 'c', 'd']
            @iter_ary = IterableArray.new @ary

            array_1, array_2 = [], []
            10.times { array_1 << @iter_ary.choice }
            10.times { array_2 <<      @ary.choice }
            array_1.should_not == array_2
        end

        it "that don't iterate work the same as array methods outside of iteration blocks", :method => :nitems do
            @ary = ['a', 'b', 'c', 'd']
            @iter_ary = IterableArray.new @ary
            @iter_ary.nitems.should == @ary.nitems
        end
    end

    describe 'modifiers outside of iteration' do
        before :each do
            @ary_1 = ['a', 'b', 'c', 'd']
            @iter_ary_1 = IterableArray.new @ary_1
            @ary_2 = ['c', 'd', 'e']
            @iter_ary_2 = IterableArray.new @ary_2
            @num = 3
        end

        it ':delete_at' do
            @iter_ary_1.delete_at(1).should == @ary_1.delete_at(1)
            @iter_ary_1.should == @ary_1

            @iter_ary_1.delete_at(-2).should == @ary_1.delete_at(-2)
            @iter_ary_1.should == @ary_1

            @iter_ary_1.delete_at(6).should == @ary_1.delete_at(6)
            @iter_ary_1.should == @ary_1
        end

        it ':shift' do
            @iter_ary_1.shift.should == @ary_1.shift
            @iter_ary_1.should == @ary_1

            @iter_ary_2.shift(2).should == @ary_2.shift(2)
            @iter_ary_2.should == @ary_2
        end

        it ':clear' do
            @iter_ary_1.clear.should == @ary_1.clear
            @iter_ary_1.should == @ary_1
        end

        it ':pop' do
            @iter_ary_1.pop.should == @ary_1.pop
            @iter_ary_1.should == @ary_1
        end
    end

    describe 'non-modifying iteration' do
        # Will probably need to have some modification methods implemented
        # before being able to *really* test iteration methods.
        # Some holpful functions... Should I put these somewhere else?
        def appender out
            lambda { |x| out << x }
        end

        def each_with_index_appender out
            lambda { |x, y| out << [x, y] }
        end

        def map_appender out
            lambda { |x| (out << x).dup }
        end

        def index_appender obj, out
            lambda { |x| out << x; x == obj }
        end

        before :each do
            @ary = ['a', 'b', 'c', 'd']
            @iter_ary = IterableArray.new @ary
            @out_1, @out_2 = [], []
        end

        def check_outs
            @out_1.should_not == []
            @out_1.should == @out_2
        end

#        it 'is this test even working?' do
#            @ary.should == ['a', 'b', 'c', 'd']
#            @iter_ary.should == IterableArray.new(['a', 'b', 'c', 'd'])
#            @ary.each(&(appender @out_1)).should == ['a', 'b', 'c', 'd']
#            @out_1.should == ['a', 'b', 'c', 'd']
#        end

        it ':each' do
            @iter_ary.each(&(appender @out_1)).should ==
                 @ary.each(&(appender @out_2))
            check_outs
            @iter_ary.each {}.should be_an_instance_of(IterableArray)
        end

        it ':each_index' do
            @iter_ary.each_index(&(appender @out_1)).should ==
                 @ary.each_index(&(appender @out_2))
            check_outs
            @iter_ary.each_index {}.should be_an_instance_of(IterableArray)
        end

        it ':each_with_index' do
            @iter_ary.each_with_index(&(each_with_index_appender @out_1)).should ==
                 @ary.each_with_index(&(each_with_index_appender @out_2))
            check_outs
            @iter_ary.each_with_index {}.should be_an_instance_of(IterableArray)
        end

        it ':reverse_each' do
            @iter_ary.reverse_each(&(appender @out_1)).should ==
                 @ary.reverse_each(&(appender @out_2))
            check_outs
            @iter_ary.reverse_each {}.should be_an_instance_of(IterableArray)
        end

        it ':map / :collect' do
            @iter_ary.map(&(appender @out_1)).should ==
                 @ary.map(&(appender @out_2))
            check_outs
            @iter_ary.map {}.should be_an_instance_of(IterableArray)
        end

        it ':map! / :collect!' do
            @iter_ary.map!(&(map_appender @out_1)).should ==
                 @ary.map!(&(map_appender @out_2))
            @iter_ary.should == @ary
            check_outs
            @iter_ary.map! {}.should be_an_instance_of(IterableArray)
        end

        it ':cycle' do
            @iter_ary.cycle(3, &(appender @out_1)).should ==
                 @ary.cycle(3, &(appender @out_2))
            check_outs
            @iter_ary.cycle(3) {}.should equal(nil)
        end

        describe ':index' do
            it do
                obj = 'c'
                @iter_ary.index(&(index_appender obj, @out_1)).should ==
                     @ary.index(&(index_appender obj, @out_2))
                check_outs
            end

            it do
                obj = 'z'
                @iter_ary.index(&(index_appender obj, @out_1)).should ==
                     @ary.index(&(index_appender obj, @out_2))
                check_outs
            end
        end

        describe ':slice!' do
            it do
                @iter_ary.slice!(2..3).should == @ary.slice!(2..3)
                @iter_ary.should == @ary
            end

            it do
                @iter_ary.slice!(-3, 2).should == @ary.slice!(-3, 2)
                @iter_ary.should == @ary
            end

            it do
                @iter_ary.slice!(1).should == @ary.slice!(1)
                @iter_ary.should == @ary
            end

            it do
                @iter_ary.slice!(2, 10).should == @ary.slice!(2, 10)
                @iter_ary.should == @ary
            end

            it do
                @iter_ary.slice!(-3..-1).should == @ary.slice!(-3..-1)
                @iter_ary.should == @ary
            end
        end
    end

    describe 'non-array methods' do
        before :each do
            @ary = ['a', 'b', 'c', 'd']
            @iter_ary = IterableArray.new @ary
            @out_1, @out_2 = [], []
        end

        it ':swap' do
            @iter_ary.swap('b', 'd').should == ['a', 'd', 'c', 'b']
        end

        it ':swap_indices' do
            @iter_ary.swap_indices(1, 3).should == ['a', 'd', 'c', 'b']
        end
    end

    # holper methods
    def eacher iterator_string=:each, *args, &block
        @batting_order.send(iterator_string, *args) do |x|
            @batting_history << x
            yield x
        end
    end

    def catch_and_eacher iterator_string=:each, *args, &block
        catch :out_of_bound do
            @batting_order.send(iterator_string, *args) do |x|
                @batting_history << x
                yield x
                throw :out_of_bound if @counter > @bound
                @counter += 1
            end

            @caught = false
        end
    end

    describe 'complex iteration' do
        before :all do
            @bound = 200
        end

        before :each do
            @batting_order = IterableArray.new [:alice, :bob, :carrie, :darryl, :eve]
            @batting_history = []

            @drop_batter = false
            @counter = 0
            @caught = true
        end

        describe 'where only simple array element assignments are made' do
            it do
                eacher do |x|
                    @batting_order[@batting_order.index x] = :maurice if x == :carrie
                end

                @batting_order.should == [:alice, :bob, :maurice, :darryl, :eve]
                @batting_history.should == [:alice, :bob, :carrie, :darryl, :eve]
            end

            it do
                eacher do |x|
                    @batting_order[@batting_order.index(x) + 1] = :maurice if x == :carrie
                end

                @batting_order.should == [:alice, :bob, :carrie, :maurice, :eve]
                @batting_history.should == [:alice, :bob, :carrie, :maurice, :eve]
            end
        end

        describe :pop do
            it do
                @ary = @batting_order.to_a
                eacher do |x|
                    @batting_order.pop.should == @ary.pop
                    break
                end
                @batting_order.should == @ary
            end

            it do
                @ary = @batting_order.to_a
                eacher do |x|
                    @batting_order.pop(3).should == @ary.pop(3)
                    break
                end
                @batting_order.should == @ary
            end
        end

        # best one evarr!
        describe 'juggling with #each and #rotate!', :method => :rotate! do
            it do
                @batting_order = IterableArray.new [:a, :b, :c, :d]
                continue_sans_rotation = true
                @bound = 18
                catch_and_eacher do |x|
                    if continue_sans_rotation then
                        continue_sans_rotation = false
                    else
                        @batting_order.rotate!  # and roll! w00t!
                    end
                end
                output = []
                5.times { output += [:a, :b, :c, :d] }
                @batting_history.should == output
            end
        end

        describe ':swap!' do
            it do
                catch_and_eacher do |x|
                    @batting_order.swap!(:bob, :carrie) if x == :darryl
                end
                @batting_history.should == [:alice, :bob, :carrie, :darryl, :eve]
                @batting_order.should == [:alice, :carrie, :bob, :darryl, :eve]
            end

            it do
                catch_and_eacher do |x|
                    @batting_order.swap!(:bob, :carrie) if x == :alice
                end
                @batting_history.should == [:alice, :carrie, :bob, :darryl, :eve]
                @batting_order.should == [:alice, :carrie, :bob, :darryl, :eve]
            end

            it do
                catch_and_eacher do |x|
                    @batting_order.swap!(:bob, :carrie) if x == :bob
                end
                @batting_history.should == [:alice, :bob, :darryl, :eve]
                @batting_order.should == [:alice, :carrie, :bob, :darryl, :eve]
            end
        end

        describe ':swap_indices!' do
            it do
                catch_and_eacher do |x|
                    @batting_order.swap_indices!(1, 2) if x == :darryl
                end
                @batting_history.should == [:alice, :bob, :carrie, :darryl, :eve]
                @batting_order.should == [:alice, :carrie, :bob, :darryl, :eve]
            end

            it do
                catch_and_eacher do |x|
                    @batting_order.swap_indices!(1, 2) if x == :alice
                end
                @batting_history.should == [:alice, :carrie, :bob, :darryl, :eve]
                @batting_order.should == [:alice, :carrie, :bob, :darryl, :eve]
            end

            it do
                catch_and_eacher do |x|
                    @batting_order.swap_indices!(1, 2) if x == :bob
                end
                @batting_history.should == [:alice, :bob, :darryl, :eve]
                @batting_order.should == [:alice, :carrie, :bob, :darryl, :eve]
            end
        end

        describe ':insert' do
            it do
                catch_and_eacher do |x|
                    @batting_order.insert(4, :franny, :zooey) if x == :darryl
                end

                @batting_order.should == [:alice, :bob, :carrie, :darryl, :franny, :zooey, :eve]
                @batting_history.should == [:alice, :bob, :carrie, :darryl, :franny, :zooey, :eve]
            end

            it do
                catch_and_eacher do |x|
                    @batting_order.insert(2, :franny, :zooey) if x == :darryl
                end

                @batting_order.should == [:alice, :bob, :franny, :zooey, :carrie, :darryl, :eve]
                @batting_history.should == [:alice, :bob, :carrie, :darryl, :eve]
            end
        end

        describe ':unshift' do
            it do
                catch_and_eacher do |x|
                    @batting_order.unshift :voice, :of, :the, :cicada if x == :alice
                end

                @batting_order.should == [:voice, :of, :the, :cicada, :alice, :bob, :carrie, :darryl, :eve]
                @batting_history.should == [:alice, :bob, :carrie, :darryl, :eve]
            end
        end

        describe ':cycle' do
            # This first one really only tests very basic behavior that
            # has probably already been tested in the non-modifying
            # iteration section. Should I get rid of it?
            it do
                catch_and_eacher :cycle, 1 do |x|
                    @batting_order.delete_at(@batting_order.index x) if @drop_batter
                    @drop_batter = true if x == :darryl
                end

                @counter.should == 5
                @caught.should be_false
                @batting_order.should == [:alice, :bob, :carrie, :darryl]
                @batting_history.should == [:alice, :bob, :carrie, :darryl, :eve]
            end

            it 'exits a finite cycle early when the array becomes empty' do
                catch_and_eacher :cycle, 5 do |x|
                    @batting_order.delete_at(@batting_order.index x) if @drop_batter
                    @drop_batter = true if x == :darryl
                end

                @counter.should == 9
                @caught.should be_false
                @batting_order.should == []
                @batting_history.should == [:alice, :bob, :carrie, :darryl, :eve, :alice, :bob, :carrie, :darryl]
            end

            it 'exits an infinite cycle when the array becomes empty' do
                catch_and_eacher :cycle do |x|
                    @batting_order.delete_at(@batting_order.index x) if @drop_batter
                    @drop_batter = true if x == :darryl
                end

                @counter.should == 9
                @caught.should be_false
                @batting_order.should == []
                @batting_history.should == [:alice, :bob, :carrie, :darryl, :eve, :alice, :bob, :carrie, :darryl]
            end

            it 'continues indefinitely for an infinite cycle when the array is modified but not emptied' do
                catch_and_eacher :cycle do |x|
                    @batting_order.delete_at(@batting_order.index x) if x == :darryl
                end

                @caught.should be_true
                @batting_order.should == [:alice, :bob, :carrie, :eve]
            end

            it 'exits after the array is cleared' do
                catch_and_eacher :cycle do |x|
                    @batting_order.clear if x == :carrie and @counter > 4
                end

                @batting_order.should == []
                @batting_history.should == [:alice, :bob, :carrie, :darryl, :eve, :alice, :bob, :carrie]
            end
        end

        describe 'where a currently yielded element is deleted' do
            it do
                eacher do |x|
                    @batting_order.delete_at(@batting_order.index x) if x == :carrie
                end
                @batting_order.should == [:alice, :bob, :darryl, :eve]
                @batting_history.should == [:alice, :bob, :carrie, :darryl, :eve]
            end
        end

        describe 'where an element after the currently yielded element is deleted' do
            it do
                eacher do |x|
                    @batting_order.pop if x == :carrie
                end
                @batting_order.should == [:alice, :bob, :carrie, :darryl]
                @batting_history.should == [:alice, :bob, :carrie, :darryl]
            end
        end

        describe 'where an element before the currently yielded element is deleted' do
            it do
                eacher do |x|
                    @batting_order.shift if x == :carrie
                end
                @batting_order.should == [:bob, :carrie, :darryl, :eve]
                @batting_history.should == [:alice, :bob, :carrie, :darryl, :eve]
            end
        end

        describe ':reverse!' do
            it do
                eacher do |x|
                    @batting_order.reverse! if x == :darryl
                end
                @batting_order.should == [:eve, :darryl, :carrie, :bob, :alice]
                @batting_history.should == [:alice, :bob, :carrie, :darryl, :carrie, :bob, :alice]
            end

            it do
                eacher do |x|
                    if x == :carrie
                        @batting_order.delete_at(@batting_order.index x)
                        @batting_order.reverse!
                    end
                end
                @batting_order.should == [:eve, :darryl, :bob, :alice]
                @batting_history.should == [:alice, :bob, :carrie, :bob, :alice]
            end
        end

        describe ":sort! the bob's" do
            describe 'one bob' do
                it do
                    @batting_order = IterableArray.new ['bob', 'darryl', 'alice', 'carrie']
                    eacher do |x|
                        @batting_order.sort! if x == 'alice'
                    end
                    @batting_order.should == ['alice', 'bob', 'carrie', 'darryl']
                    @batting_history.should == ['bob', 'darryl', 'alice', 'bob', 'carrie', 'darryl']
                end
            end

            describe "multiple bob's" do
                before :each do
                    @batting_order = IterableArray.new ['alice', 'bob', 'darryl', 'bob', 'darryl', 'carrie', 'bob']
                    @bob_counter = 0
                end

                it 'first bob' do
                    eacher do |x|
                        @bob_counter += 1 if x == 'bob'
                        @batting_order.sort! if @bob_counter == 1
                    end

                    @batting_history.should == ['alice', 'bob', 'bob', 'bob', 'carrie', 'darryl', 'darryl']
                end

                it 'second bob' do
                    eacher do |x|
                        @bob_counter += 1 if x == 'bob'
                        @batting_order.sort! if @bob_counter == 2
                    end

                    @batting_history.should == ['alice', 'bob', 'darryl', 'bob', 'bob', 'carrie', 'darryl', 'darryl']
                end

                it 'third bob' do
                    eacher do |x|
                        @bob_counter += 1 if x == 'bob'
                        @batting_order.sort! if @bob_counter == 3
                    end

                    @batting_history.should == ['alice', 'bob', 'darryl', 'bob', 'darryl', 'carrie', 'bob', 'carrie', 'darryl', 'darryl']
                end
            end
        end

        describe ':shuffle! the bob\'s' do
            it 'one bob' do
                class Array
                    alias_method :old_shuffle!, :shuffle!
                    def shuffle!
                        if self == ['alice', 'bob', 'carrie', 'darryl']
                            replace ['bob', 'alice', 'carrie', 'darryl']
                            Array.class_exec { alias_method :shuffle!, :old_shuffle! }
                            return self
                        end
                        old_shuffle!
                    end
                end


                @batting_order = IterableArray.new ['alice', 'bob', 'carrie', 'darryl']
                eacher do |x|
                    @batting_order.shuffle! if x == 'bob'
                end

                @batting_order.should == ['bob', 'alice', 'carrie', 'darryl']
                @batting_history.should == ['alice', 'bob', 'alice', 'carrie', 'darryl']
            end

            it "multiple bob's", :method => :sample do
                class Array
                    alias_method :old_shuffle!, :shuffle!
                    def shuffle!
                        if self == ['alice', 'bob', 'bob', 'bob', 'carrie', 'darryl', 'darryl']
                            replace ['carrie', 'bob', 'darryl', 'darryl', 'bob', 'bob', 'alice']
                            Array.class_exec { alias_method :shuffle!, :old_shuffle! }
                            return self
                        end
                        old_shuffle!
                    end

                    # Note: The use of Array#sample is implementation specific.
                    alias_method :old_sample, :sample
                    def sample
                        Array.class_exec {alias_method :sample, :old_sample }
                        at 2
                    end
                end


                @batting_order = IterableArray.new ['alice', 'bob', 'bob', 'bob', 'carrie', 'darryl', 'darryl']
                @batting_history = []
                @bob_counter = 0

                eacher do |x|
                    @bob_counter += 1 if x == 'bob'
                    if @bob_counter == 2
                        @batting_order.shuffle!
                        @bob_counter += 1
                    end
                end

                @batting_order.should == ['carrie', 'bob', 'darryl', 'darryl', 'bob', 'bob', 'alice']
                @batting_history.should == ['alice', 'bob', 'bob', 'alice']
            end
        end

        describe 'catching a break' do
            it do
                result = eacher do |x|
                    break if x == :bob
                end

                @batting_order.instance_exec { @array.kind_of? Array }.should be_true
                @batting_order.instance_exec { @array.kind_of? IterableArray }.should be_false
                @batting_history.should == [:alice, :bob]
                result.should == nil
            end

            it do
                result = catch :a_break do
                    eacher do |x|
                        throw :a_break if x == :bob
                    end
                end

                @batting_order.instance_exec { @array.kind_of? Array }.should be_true
                @batting_order.instance_exec { @array.kind_of? IterableArray }.should be_false
                @batting_history.should == [:alice, :bob]
                result.should == nil
            end
        end

        describe 'tracking' do
            it do
                eacher :reverse_each do |x|
                    if x == :carrie
                        @batting_order.delete_at(@batting_order.index x)
                        @batting_order.swap! :darryl, :eve
                    end
                end
                @batting_order.should == [:alice, :bob, :eve, :darryl]
                @batting_history.should == [:eve, :darryl, :carrie, :bob, :alice]
            end

            it do
                eacher :reverse_each do |x|
                    if x == :carrie
                        @batting_order.delete_at(@batting_order.index x)
                        @batting_order.swap! :bob, :alice
                    end
                end
                @batting_order.should == [:bob, :alice, :darryl, :eve]
                @batting_history.should == [:eve, :darryl, :carrie, :bob]
            end

            it do
                eacher do |x|
                    if x == :carrie
                        @batting_order.delete_at(@batting_order.index x)
                        @batting_order.reverse!
                        @batting_order.swap! :bob, :alice
                    end
                end
                @batting_order.should == [:eve, :darryl, :alice, :bob]
                @batting_history.should == [:alice, :bob, :carrie, :bob]
            end

            it do
                eacher :reverse_each do |x|
                    if x == :carrie
                        @batting_order.delete_at(@batting_order.index x)
                        @batting_order.reverse!
                        @batting_order.swap! :bob, :alice
                    end
                end
                @batting_order.should == [:eve, :darryl, :alice, :bob]
                @batting_history.should == [:eve, :darryl, :carrie, :darryl, :eve]
            end

            pending 'toggle tracking' do
            end
        end
    end

    describe 'nested iteration' do
        before :all do
            @bound = 200
        end

        before :each do
            @batting_order = IterableArray.new [:alice, :bob, :carrie, :darryl]
            @batting_history = []

            @drop_batter = false
            @counter = 0
            @caught = true
        end

        it do
            eacher do |x|
                if x == :bob
                    eacher do |x|
                        @batting_order.delete_at(@batting_order.index x) if x == :bob
                    end
                end
            end
            @batting_history.should == [:alice, :bob, :alice, :bob, :carrie, :darryl, :carrie, :darryl]
        end

        it do
            eacher do |x|
                if x == :carrie
                    eacher do |x|
                        @batting_order.delete_at(@batting_order.index x) if x == :bob or x == :darryl
                    end
                end
            end
            @batting_history.should == [:alice, :bob, :carrie, :alice, :bob, :carrie, :darryl]
        end

        describe ':reverse_each' do
            it do
                eacher :reverse_each do |x|
                    if x == :carrie
                        eacher do |x|
                            @batting_order.delete_at(@batting_order.index x) if x == :alice
                        end
                    end
                end
                @batting_history.should == [:darryl, :carrie, :alice, :bob, :carrie, :darryl, :bob]
            end

            it do
                eacher :reverse_each do |x|
                    if x == :carrie
                        @batting_order.delete_at(@batting_order.index x)  # [:alice, :bob, <- :darryl]
                        eacher do |x|  # [ -> :alice, :bob, :darryl]
                            if x == :bob  # [:alice, -> :bob, :darryl]
                                eacher :reverse_each do |x|
                                    @batting_order.delete_at(@batting_order.index x)
                                    @batting_order.push(:eve) if x == :bob
                                end
                            end
                        end
                    end
                end
                @batting_order.should == [:eve]
                @batting_history.should == [:darryl, :carrie, :alice, :bob, :darryl, :bob, :alice, :eve, :eve]
            end
        end

        describe ':delete_if' do
            it do
                eacher do |x|
                    if x == :carrie
                        @batting_order.delete_if { |x| @batting_history << x; x == :bob }
                    end
                end
                @batting_history.should == [:alice, :bob, :carrie, :alice, :bob, :carrie, :darryl, :darryl]
                @batting_order.should == [:alice, :carrie, :darryl]
            end
        end

        describe ':sort! and :delete_if...together for the first time for your titillation' do
            it do
                @batting_order = IterableArray.new ['bob', 'darryl', 'alice', 'carrie']
                eacher do |x|
                    if x == 'alice'
                        eacher :delete_if do |x|
                            @batting_order.sort! if x == 'alice'
                            x == 'carrie'
                        end
                    end
                end
                @batting_order.should == ['alice', 'bob', 'darryl']
                @batting_history.should == ['bob', 'darryl', 'alice', 'bob', 'darryl', 'alice', 'bob', 'carrie', 'darryl', 'bob', 'darryl']
            end
        end
    end

    describe 'comb-perm methods' do
        before :all do
            @target = 'c'
            @ferigner = 'q'
        end

        before :each do
            @ary_1 = ['a', 'b', 'c', 'd', 'e']
            @iter_ary_1 = IterableArray.new @ary_1
            @happy_holder = []
            @cozy_container = []
            @counter = 0
        end

        comb_perm_template = lambda do |methd|
            describe methd.to_s, :method => methd do
                it 'acts like the normal feller from Array in the absence of modification' do
                    @ary_1.method(methd).call(3) { |item| @happy_holder << item }
                    @iter_ary_1.method(methd).call(3) { |item| @cozy_container << item }
                    @happy_holder.should == @cozy_container
                end

                it "does not yield #{methd}s containing deleted array elements" do
                    @iter_ary_1.method(methd).call(3) do |item|
                        @cozy_container += item
                        @happy_holder += item if @counter > 5
                        @iter_ary_1.delete @target if @counter == 5
                        @counter += 1
                    end
                    @cozy_container.include?(@target).should be_true
                    @happy_holder.include?(@target).should be_false
                end

                it "yields #{methd}s containing added array elements" do
                    @iter_ary_1.method(methd).call(3) do |item|
                        @cozy_container += item if @counter <= 5
                        @happy_holder += item if @counter > 5
                        @iter_ary_1.unshift @ferigner if @counter == 5
                        @counter += 1
                    end
                    @iter_ary_1.include?(@ferigner).should be_true
                    @cozy_container.include?(@ferigner).should be_false
                    @happy_holder.include?(@ferigner).should be_true
                end
            end
        end

        [
            :permutation,
            :combination,
            :repeated_permutation,
            :repeated_combination
        ].each { |methd| comb_perm_template[methd] }
    end
end
