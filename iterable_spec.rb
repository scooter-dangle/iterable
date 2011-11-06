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
            @iter_array.first(3).should    be_an_instance_of(IterableArray)
        end
    end
end
