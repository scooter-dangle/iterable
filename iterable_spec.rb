require File.join(File.dirname(__FILE__),'iterable.rb'
# require '~/iterable/iterable.rb'


describe IterableArray do
    it 'should not claim to be an Array' do
        @iter_ary = IterableArray.new
        @iter_ary.class.should_not == Array
    end

    pending('should respond to every Array instance method') do # MAYbe...
        @iter_ary = IterableArray.new
        Array.instance_methods.each do |method|
            @iter_ary.should respond_to(method)
        end
    end

    describe ':assoc and :rassoc' do
        it 'should work like Array#assoc and Array#rassoc but also return IterableArrays' do
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
        it 'should return false for differing array content' do
            @ary_1 = [ 0, 1, 2 ]
            @iter_ary_1 = IterableArray.new [ 'a', 'b', 'c' ]
            ( @iter_ary_1 == @ary_1 ).should be_false
            ( @ary_1 == @iter_ary_1 ).should be_false
        end

        it 'should return true if array content matches but classes differ' do
            @ary_1 = [ 0, 1, 2 ]
            @iter_ary_1 = IterableArray.new @ary_1
            ( @iter_ary_1 == @ary_1 ).should be_true
            ( @ary_1 == @iter_ary_1 ).should be_true
        end
    end


    it ":eql? should act like a class-sensitive version of :==" do
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
        it 'should not include :nitems since :nitems is not in 1.9.x' do
            @iter_ary = IterableArray.new [ 'a', 'b', 'c' ]
            @iter_ary.singleton_class.instance_methods.should_not include(:nitems)
        end

        it 'should return an InterableArray when the corresponding Array method would return an array' do
            @iter_ary = IterableArray.new [ 'a', 'b', 'c', 'd' ]
            @ary = [ 0, 1, 2, 3 ]
            num   = 3
            ( @iter_ary & @ary ).should be_an_instance_of(IterableArray)
            ( @iter_ary + @ary ).should be_an_instance_of(IterableArray)
            ( @iter_ary - @ary ).should be_an_instance_of(IterableArray)
            ( @iter_ary | @ary ).should be_an_instance_of(IterableArray)
            ( @iter_ary * num   ).should be_an_instance_of(IterableArray)
            ( @iter_ary << num  ).should be_an_instance_of(IterableArray)
            @iter_ary[1, 2].should be_an_instance_of(IterableArray)
            @iter_ary[1...num].should be_an_instance_of(IterableArray)
            @iter_ary.values_at(1...num).should be_an_instance_of(IterableArray)
            @iter_ary.values_at(0).should be_an_instance_of(IterableArray)
            @iter_ary.values_at(1, 0).should be_an_instance_of(IterableArray)
            @iter_ary.indices((1..2)).should be_an_instance_of(IterableArray)
            @iter_ary.indexes((1..2)).should be_an_instance_of(IterableArray)
            ( @iter_ary << num  ).should be_an_instance_of(IterableArray)
            @iter_ary.first(3).should    be_an_instance_of(IterableArray)
            @iter_ary.last(3).should    be_an_instance_of(IterableArray)
        end

        it "that don't iterate should work the same as array methods outside of iteration blocks" do
            @ary = [ 'a', 'b', 'c', 'd' ]
            @iter_ary = IterableArray.new @ary
            @ary_2 = [ 'c', 'd', 'e' ]
            @iter_ary_2 = IterableArray.new @ary_2
            num   = 3

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
        end
    end
end
