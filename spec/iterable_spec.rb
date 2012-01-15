require File.join(File.split(File.dirname(__FILE__))[0], 'lib', 'iterable.rb')


describe IterableArray do
    it 'does not claim to be an Array' do
        @iter_ary = IterableArray.new
        @iter_ary.class.should_not == Array
        @iter_ary.class.should == IterableArray
    end

    pending 'responds to every Array instance method' do # MAYbe...
        @iter_ary = IterableArray.new
        Array.instance_methods(false).each do |method|
            @iter_ary.should respond_to(method)
        end

        @iter_ary = IterableArray.new [1]
        @iter_ary.each do
            Array.instance_methods(false).each do |method|
                @iter_ary.should respond_to(method)
            end
        end
    end

    pending 'responds to every Enumerable instance method' do # MAYbe...
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
        it 'work like Array#assoc and Array#rassoc but return IterableArrays' do
            @ary = [ 42, [ 'x', 'y', 'z' ], [ 0, 1, 2 ], IterableArray.new( [ :alpha, :beta, :gamma ] ) ]
            @iter_ary = IterableArray.new @ary

            @iter_ary.assoc(0).should == @ary.assoc(0)
            @iter_ary.assoc(1).should == @ary.assoc(1)
            @iter_ary.assoc(:alpha).should == [ :alpha, :beta, :gamma ]
            @iter_ary.assoc(:beta).should == nil

            @iter_ary.rassoc(0).should == @ary.rassoc(0)
            @iter_ary.rassoc(1).should == @ary.rassoc(1)
            @iter_ary.rassoc(:alpha).should == nil
            @iter_ary.rassoc(:beta).should == [ :alpha, :beta, :gamma ]
        end
    end

    # Testing :== might be overkill, but I want to be safe since rspec uses it
    # every time I do "___.should == ___"
    describe ':==' do
        it 'returns false for differing array content' do
            @ary_1 = [ 0, 1, 2 ]
            @iter_ary_1 = IterableArray.new [ 'a', 'b', 'c' ]
            ( @iter_ary_1 == @ary_1 ).should be_false
            ( @ary_1 == @iter_ary_1 ).should be_false
        end

        it 'returns true if array content matches but classes differ' do
            @ary_1 = [ 0, 1, 2 ]
            @iter_ary_1 = IterableArray.new @ary_1
            ( @iter_ary_1 == @ary_1 ).should be_true
            ( @ary_1 == @iter_ary_1 ).should be_true
        end
    end


    it ':eql? acts like a class-sensitive version of :==' do
        @ary_1 = [ 0, 1, 2 ]
        @ary_2 = [ 'a', 'b', 'c' ]
        @iter_ary_1 = IterableArray.new @ary_1
        @iter_ary_2 = IterableArray.new @ary_1
        @iter_ary_3 = IterableArray.new @ary_2
        @iter_ary_1.eql?(@ary_1).should be_false
        @iter_ary_1.eql?(@iter_ary_2).should be_true
        @iter_ary_1.eql?(@iter_ary_3).should be_false
    end


    describe 'instance methods' do
        if RUBY_VERSION >= '1.9'
            it 'do not include :nitems since :nitems is not in 1.9.x' do
                @iter_ary = IterableArray.new [ 'a', 'b', 'c' ]
                @iter_ary.singleton_class.instance_methods.should_not include(:nitems)
            end
        end

        it 'return an InterableArray when the corresponding Array method would return an array' do
            @iter_ary = IterableArray.new [ 'a', 'b', 'c', 'd' ]
            @ary = [ 0, 1, 2, 3 ]
            num   = 3
            ( @iter_ary & @ary )        .should be_an_instance_of(IterableArray)
            ( @iter_ary + @ary )        .should be_an_instance_of(IterableArray)
            ( @iter_ary - @ary )        .should be_an_instance_of(IterableArray)
            ( @iter_ary | @ary )        .should be_an_instance_of(IterableArray)
            ( @iter_ary * num  )        .should be_an_instance_of(IterableArray)
            ( @iter_ary << num )        .should be_an_instance_of(IterableArray)
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
        end

        it "that don't iterate work the same as array methods outside of iteration blocks" do
            @ary = [ 'a', 'b', 'c', 'd' ]
            @iter_ary = IterableArray.new @ary
            @ary_2 = [ 'c', 'd', 'e' ]
            @iter_ary_2 = IterableArray.new @ary_2
            num = 3

            # :<<
            ( @iter_ary << num ).should == ( @ary << num)

            # :<=>
            ( @iter_ary <=> @iter_ary_2 ).should == ( @ary <=> @ary_2 )
            ( @iter_ary_2 <=> @iter_ary ).should == ( @ary_2 <=> @ary )
            ( @iter_ary <=> @iter_ary ).should == ( @ary <=> @ary )

            # :&
            ( @iter_ary_2 & @ary ).should == ( @ary_2 & @ary)

            # :|
            ( @iter_ary_2 | @ary ).should == ( @ary_2 | @ary)

            # :+
            ( @iter_ary + @ary ).should == ( @ary + @ary)

            # :-
            ( @iter_ary_2 - @ary ).should == ( @ary_2 - @ary)

            # :+
            ( @iter_ary + @ary ).should == ( @ary + @ary)

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
        end
    end

    describe 'non-modifying iteration' do
        # Will probably need to have some modification methods implemented
        # before being able to *really* test iteration methods.
        before :all do
            @out_1, @out_2 = [], []
        end

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
            @ary = [ 'a', 'b', 'c', 'd' ]
            @iter_ary = IterableArray.new @ary
            @out_1, @out_2 = [], []
        end

        def check_outs
            @out_1.should_not == []
            @out_1.should == @out_2
        end

#        it 'is this test even working?' do
#            @ary.should == [ 'a', 'b', 'c', 'd' ]
#            @iter_ary.should == IterableArray.new([ 'a', 'b', 'c', 'd' ])
#            @ary.each(&(appender @out_1)).should == [ 'a', 'b', 'c', 'd' ]
#            @out_1.should == [ 'a', 'b', 'c', 'd' ]
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
    end

    describe 'complex iteration' do
        before :all do
            @bound = 200
        end

        before :each do
            @batting_order = IterableArray.new [ :alice, :bob, :carrie, :darryl, :eve ]
            @out = []

            @drop_player = false
            @counter = 0
            @caught = true
        end

        describe 'where only simple array element assignments are made' do
            it do
                @batting_order.each do |x|
                    @out << x
                    @batting_order[@batting_order.index x] = :maurice if x == :carrie
                end
                @batting_order.should == [ :alice, :bob, :maurice, :darryl, :eve ]
                @out.should == [ :alice, :bob, :carrie, :darryl, :eve ]
            end

            it do
                @batting_order.each do |x|
                    @out << x
                    @batting_order[@batting_order.index(x) + 1] = :maurice if x == :carrie
                end
                @batting_order.should == [ :alice, :bob, :carrie, :maurice, :eve ]
                @out.should == [ :alice, :bob, :carrie, :maurice, :eve ]
            end
        end

        describe ':cycle' do
            # This first one really only tests very basic behavior that
            # has probably already been tested in the non-modifying
            # iteration section. Should I get rid of it?
            it do
                catch :out_of_bound do
                    @batting_order.cycle(1) do |x|
                        @out << x
                        @batting_order.delete_at(@batting_order.index x) if @drop_player
                        @drop_player = true if x == :darryl
                        throw :out_of_bound if @counter > @bound
                        @counter += 1
                    end
                    @caught = false
                end

                @counter.should == 5
                @caught.should be_false
                @batting_order.should == [ :alice, :bob, :carrie, :darryl ]
                @out.should == [ :alice, :bob, :carrie, :darryl, :eve ]
            end

            it 'exits a finite cycle early when the array becomes empty' do
                catch :out_of_bound do
                    @batting_order.cycle(5) do |x|
                        @out << x
                        @batting_order.delete_at(@batting_order.index x) if @drop_player
                        @drop_player = true if x == :darryl
                        throw :out_of_bound if @counter > @bound
                        @counter += 1
                    end
                    @caught = false
                end

                @counter.should == 9
                @caught.should be_false
                @batting_order.should == []
                @out.should == [ :alice, :bob, :carrie, :darryl, :eve, :alice, :bob, :carrie, :darryl ]
            end

            it 'exits an infinite cycle when the array becomes empty' do
                catch :out_of_bound do
                    @batting_order.cycle do |x|
                        @out << x
                        @batting_order.delete_at(@batting_order.index x) if @drop_player
                        @drop_player = true if x == :darryl
                        throw :out_of_bound if @counter > @bound
                        @counter += 1
                    end
                    @caught = false
                end

                @counter.should == 9
                @caught.should be_false
                @batting_order.should == []
                @out.should == [ :alice, :bob, :carrie, :darryl, :eve, :alice, :bob, :carrie, :darryl ]
            end

            it 'continues indefinitely for an infinite cycle when the array is modified but not emptied' do
                catch :out_of_bound do
                    @batting_order.cycle do |x|
                        @batting_order.delete_at(@batting_order.index x) if x == :darryl
                        throw :out_of_bound if @counter > @bound
                        @counter += 1
                    end
                    @caught = false
                end

                @caught.should be_true
                @batting_order.should == [ :alice, :bob, :carrie, :eve ]
            end
        end

        describe 'where a currently yielded element is deleted' do
            it do
                @batting_order.each do |x|
                    @out << x
                    @batting_order.delete_at(@batting_order.index x) if x == :carrie
                end
                @batting_order.should == [ :alice, :bob, :darryl, :eve ]
                @out.should == [ :alice, :bob, :carrie, :darryl, :eve ]
            end
        end

        describe 'where an element after the currently yielded element is deleted' do
            it do
                @batting_order.each do |x|
                    @out << x
                    @batting_order.pop if x == :carrie
                end
                @batting_order.should == [ :alice, :bob, :carrie, :darryl ]
                @out.should == [ :alice, :bob, :carrie, :darryl ]
            end
        end

        describe 'where an element before the currently yielded element is deleted' do
            it do
                @batting_order.each do |x|
                    @out << x
                    @batting_order.shift if x == :carrie
                end
                @batting_order.should == [ :bob, :carrie, :darryl, :eve ]
                @out.should == [ :alice, :bob, :carrie, :darryl, :eve ]
            end
        end

        it 'qjq' do
            @batting_order.each do |x|
                @out << x
                @batting_order.reverse! if x == :darryl
            end
            @batting_order.should == [ :eve, :darryl, :carrie, :bob, :alice ]
            @out.should == [ :alice, :bob, :carrie, :darryl, :carrie, :bob, :alice ]
        end

        it 'qjq' do
            @batting_order.each do |x|
                @out << x
                if x == :carrie
                    @batting_order.delete_at(@batting_order.index x)
                    @batting_order.reverse!
                end
            end
            @batting_order.should == [ :eve, :darryl, :bob, :alice ]
            @out.should == [ :alice, :bob, :carrie, :bob, :alice ]
        end
    end
end
