require File.expand_path('../array', __FILE__)
require File.expand_path('../iterable_array', __FILE__)
# Required for ruby 1.8 compatibility by Iterable::Array#shuffle! during iteration
require File.expand_path('../sampler', __FILE__)
require File.expand_path('../swapable', __FILE__)

require File.expand_path('../iterable/aliases', __FILE__)
require File.expand_path('../iterable/array', __FILE__)
require File.expand_path('../iterable/manager', __FILE__)
require File.expand_path('../iterable/version', __FILE__)

module Iterable
end

