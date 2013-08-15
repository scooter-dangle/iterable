class Sampler < Array
    if Array.new.respond_to? :sample
        # Do nothing
    elsif Array.new.respond_to? :choice
        alias_method :sample, :choice
    else
        # Don't need to allow args if this is just being
        # used in the implementation of IterableArray#shuffle!
        def sample
            at rand size
        end
    end
end
