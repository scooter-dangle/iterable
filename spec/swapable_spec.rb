require File.expand_path('../../lib/swapable', __FILE__)
require File.expand_path('../spec_helper', __FILE__)

describe Swapable do
    before(:each) { @ary =  [*'a' .. 'e']; @swappy = @ary.dup.extend Swapable }

    describe :dup do
        example { @swappy.dup.should == @ary }
        example { @swappy.dup.should be_a_kind_of Swapable }
    end

    describe :less do
        example { @swappy.less.should == @ary }
        example { @swappy.less.should == @swappy }
        example { @swappy.less.should be_a_kind_of Swapable }
        example { @swappy.less('b').should == (@ary - ['b']) }
        example { @swappy.less('b', 'd').should == (@ary - ['b', 'd']) }
        example { @swappy.less('b').less('d').should == (@ary - ['b', 'd']) }
    end

    describe :swap do
        example { @swappy.swap('b', 'e').should == ['a', 'e', 'c', 'd', 'b'] }
        example { @swappy.swap('b', 'e').should_not == @ary }
        example { @swappy.swap('b', 'e').should be_a_kind_of Swapable }
        example { @swappy.swap('b', 'e').swap('b', 'e').should == @ary }
        example { @swappy.swap('b', 'c', 'e').should == ['a', 'c', 'e', 'd', 'b'] }
        example { @swappy.swap('b', 'c', 'e').swap('b', 'c', 'e').swap('b', 'c', 'e').should == @ary }
    end

    describe :swap! do
        example { @swappy.swap!('b', 'e').should == ['a', 'e', 'c', 'd', 'b'] }
        example { @swappy.swap!('b', 'e'); @swappy.should == ['a', 'e', 'c', 'd', 'b'] }
        example { @swappy.swap!('b', 'e'); @swappy.should_not == @ary }
        example { @swappy.swap('b', 'e').should be_a_kind_of Swapable }
        example { @swappy.swap!('b', 'e').swap!('b', 'e').should == @ary }
        example { @swappy.swap!('b', 'e').swap!('b', 'e'); @swappy.should == @ary }
    end
end
