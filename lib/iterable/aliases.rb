module Iterable::Aliases
    # Need to be able to still refer to the external Array class
    # even after defining the Iterable::Array module.
    Array = [].class
end
