desc 'Build gem from gemspec'
task :gem_build do
    sh %{gem build *.gemspec}
end

desc 'Increment minor version number'
task :gem_incr do
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

desc 'Install gem'
task :gem_install do
    sh %{gem uninstall iterable}
    sh %{gem install --local --prerelease --no-ri --no-rdoc *.gem}
end

desc 'Build and install gem from gemspec and cleanup'
task gem: [:gem_incr, :gem_build, :gem_install] do
    sh %{rm *.gem}
end
