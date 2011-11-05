require '~/iterable/iterable.rb'

describe IterableArray do
    it 'should not claim to be an Array' do
        @itArray = IterableArray.new
        @itArray.class.should_not == Array
    end

    it 'should respond to every Array instance method' do # MAYbe...
        @itArray = IterableArray.new
        Array.instance_methods.each do |method|
            @itArray.should respond_to(method)
        end
    end

    describe 'instance methods' do
        it 'should return an InterableArray when the corresponding Array method would return an array'
    end
end
