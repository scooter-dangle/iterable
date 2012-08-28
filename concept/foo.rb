# ------------------------------------------------------------------------------
#
# The following is an example of how I'm probably going to try to arrange
# my methods into modules for rdoc and mixology even when mixology doesn't
# work with many ruby engines/implementations.
# (see also: fleem.rb)
#
# ------------------------------------------------------------------------------

$__FOO_STATE_CHANGE__ =
    # The test here should actually be for whether we can load up mixology
    case 'rubinius'
    # case RUBY_ENGINE
    when 'ruby' then :normal
    else :special
    end

require 'mixology' if $__FOO_STATE_CHANGE__ == :normal
# require 'pry' # insert a call to pry at the end of this file to test the
                # described behavior

class Foo
    def greeting
        'Hullo, werld!'
    end
end

$fleem_location = "#{File.expand_path File.dirname __FILE__}/fleem.rb"

case $__FOO_STATE_CHANGE__
when :normal
    require $fleem_location
when :special
    class Foo
        @@fleem_methods = IO.read($fleem_location).scan(/__BEGIN_MODULE_METHODS__\n (.*\n) [^\n]*__END_MODULE_METHODS__/xm).first.first

        eval "def mixin_fleem
            class << self
                #{@@fleem_methods}
            end
        end"
    end
end


# ------------------------------------------------------------------------------
# Behavior:
# ------------------------------------------------------------------------------
# blerg = Foo.new     => #<Foo:0x8f2d2dc>
# blerg.greeting       => "Hullo, werld!"
# blerg.mixin_fleem    => nil
# blerg.greeting       => "Horgulty Forgulty"
