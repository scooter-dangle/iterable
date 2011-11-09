require '~/iterable/iterable.rb'

describe IterableArray do
    it 'should not claim to be an Array' do
        @iter_array = IterableArray.new
        @iter_array.class.should_not == Array
    end

    pending('should respond to every Array instance method') do # MAYbe...
        @iter_array = IterableArray.new
        Array.instance_methods.each do |method|
            @iter_array.should respond_to(method)
        end
    end


    # Testing :== might be overkill, but I want to be safe since rspec uses it
    # every time I do "___.should == ___"
    describe ':==' do
        it 'should return false for differing array content' do
            array_1 = [ 0, 1, 2 ]
            @iter_array_1 = IterableArray.new [ 'a', 'b', 'c' ]
            ( @iter_array_1 == array_1 ).should be_false
            ( array_1 == @iter_array_1 ).should be_false
        end

        it 'should return true if array content matches but classes differ' do
            array_1 = [ 0, 1, 2 ]
            @iter_array_1 = IterableArray.new array_1
            ( @iter_array_1 == array_1 ).should be_true
            ( array_1 == @iter_array_1 ).should be_true
        end
    end


    it ":eql? should act like a class-sensitive version of :==" do
        array_1 = [ 0, 1, 2 ]
        array_2 = [ 'a', 'b', 'c' ]
        @iter_array_1 = IterableArray.new array_1
        @iter_array_2 = IterableArray.new array_1
        @iter_array_3 = IterableArray.new array_2
        @iter_array_1.eql?(array_1).should be_false
        @iter_array_1.eql?(@iter_array_2).should be_true
        @iter_array_1.eql?(@iter_array_3).should be_false
    end


    describe 'instance methods' do
        it 'should return an InterableArray when the corresponding Array method would return an array' do
            @iter_array = IterableArray.new [ 'a', 'b', 'c' ]
            array = [ 0, 1, 2 ]
            num   = 3
            ( @iter_array & array ).should be_an_instance_of(IterableArray)
            ( @iter_array + array ).should be_an_instance_of(IterableArray)
            ( @iter_array - array ).should be_an_instance_of(IterableArray)
            ( @iter_array * num   ).should be_an_instance_of(IterableArray)
            ( @iter_array << num  ).should be_an_instance_of(IterableArray)
            @iter_array.values_at(0..2).should be_an_instance_of(IterableArray)
            @iter_array.indices(1..2).should be_an_instance_of(IterableArray)
            @iter_array.indexes(1..2).should be_an_instance_of(IterableArray)
            ( @iter_array << num  ).should be_an_instance_of(IterableArray)
            @iter_array.first(3).should    be_an_instance_of(IterableArray)
            # @iter_array.last(3).should    be_an_instance_of(IterableArray)
        end

        it "that don't iterate should work the same as array methods outside of iteration blocks" do
            array = [ 'a', 'b', 'c' ]
            @iter_array = IterableArray.new array

            # :first
            @iter_array.first.should == array.first
            @iter_array.first(2).should == array.first(2)

            # :*
            (@iter_array * ' ').should == (array * ' ')
            (@iter_array * 2).should == (array * 2)

            # :last
            # @iter_array.last.should == array.last
            # @iter_array.last(2).should == array.last(2)
        end
    end
end
