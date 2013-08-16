class Iterable::Manager
    attr_reader :client,
        :current_index, :forward_index, :backward_index,
        :tracking

    def initialize client, mthd, *args, &block
        @client = client
        # TODO
    end

    def increment_indices
        @current_index  = @forward_index
        @forward_index  = @current_index + 1
        @backward_index = @current_index - 1
    end

    def center_indices_at new_index
        movement = @current_index - new_index
        @current_index  -= movement
        @forward_index  -= movement
        @backward_index -= movement
    end

end
