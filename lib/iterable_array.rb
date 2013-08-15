# Only present for backward compatibility. Instead, create a regular array
# and extend it with Iterable::Array
class IterableArray
    def self.new *args
        Array.new(*args).extend Iterable::Array
    end
end
