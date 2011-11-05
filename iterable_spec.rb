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

    it 'should return an IterableArray for every method in @@array_accessors'

end
