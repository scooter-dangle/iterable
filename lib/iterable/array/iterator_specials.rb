module Iterable::Array::IteratorSpecials
    # specials
    # TODO: either ensure that the following methods are being undefined
    # during #debastardize or make them private... currently they aren't
    # being undefined.
    # TODO: Also, these currently fail in a nested iteration block if they're
    # called from the main instance of Iterable::Array...they'll only affect
    # the outermost iteration block when called by a user (but they should
    # work fine when called internally)
    public
    # untested
    def invert_tracking
        @tracking *= -1
        tracking
    end

    # Need to add some minimal documentation on tracking.
    # untested
    def invert_tracking_at nesting_level = -1
        direct_to nesting_level, &:invert_tracking
    end

    # untested
    def tracking
        case @tracking < 0
        when true  then :aft
        when false then :fore
        end
    end

    # untested
    def tracking_at nesting_level = -1
        direct_to nesting_level, &:tracking
    end

    # untested
    def tracking= orient
        @tracking = case orient
                    when :aft  then @tracking.abs * -1
                    when :fore then @tracking.abs
                    end
        tracking
    end

    # untested
    def tracking_at= orient, nesting_level = -1
        direct_to nesting_level do |obj|
            obj.tracking = orient
        end
    end

    protected
    # untested
    def direct_to nesting_level
        case
        when nesting_level == 0
            yield self
        when nesting_level < 0
            @array.kind_of? Array ?
                direct_to(0) :
                @array.direct_to(-1)
        else
            @array.direct_to(nesting_level - 1)
        end
    end
end
