desc 'Build gem from gemspec'
task :build do
    sh %{gem build *.gemspec}
end

desc 'Increment minor version number'
task :incr do
    str = IO.read 'iterable.gemspec'
    str.gsub!(/(
                   \. version [^\n]*
                   ('|")
                   \d{1,} \.
                   \d{1,} \.
               )
               (\d{1,})
               (
                   (|\.pre)
                   ('|")
               )
              /x
    ) { "#$1#{$3.succ}#$4" }


    File.write 'iterable.gemspec', str
end

desc 'Uninstall gem'
task :uninstall do
    sh %{gem uninstall iterable}
end

desc 'Install gem'
task :install do
    sh %{gem install --local --prerelease --no-ri --no-rdoc *.gem}
end

desc 'Build and install gem from gemspec and cleanup'
task gem: [:build, :uninstall, :install] do
    sh %{rm *.gem}
end

desc 'Run tests'
task :test do
    sh %{rspec}
end

task default: [:build, :install, :test]

