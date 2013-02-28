require 'date'
Gem::Specification.new do |o|
    o                .name = 'iterable'
    o             .version = '0.0.7.pre'
    o              .author = 'Scott L Steele'
    o             .license = ''
    o                .date = Date.today.to_s
    o             .summary = 'Provides a fully iterable array object'
    o         .description = ''
    o               .email = 'ScottLSteele@gmail.com'
    o            .homepage = 'https://github.com/scooter-dangle/iterable'
    o               .files = Dir['lib{/*,}/*.rb']
end
