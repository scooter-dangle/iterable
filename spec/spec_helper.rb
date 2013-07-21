RSpec.configure do |c|
    c.filter_run_excluding :method => lambda {|mthd|
        # Results in slightly less test coverage for Ruby 1.8
        not Array.new.respond_to? mthd
    }
end
