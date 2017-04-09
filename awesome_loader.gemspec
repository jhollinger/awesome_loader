require_relative 'lib/awesome_loader/version'

Gem::Specification.new do |s|
  s.name = 'awesome_loader'
  s.version = AwesomeLoader::VERSION
  s.licenses = ['MIT']
  s.summary = "An awesome way to autoload your Ruby application"
  s.description = "An awesome wrapper for Ruby's built-in autoload"
  s.date = '2017-04-10'
  s.authors = ['Jordan Hollinger']
  s.email = 'jordan.hollinger@gmail.com'
  s.homepage = 'https://github.com/jhollinger/awesome_loader'
  s.require_paths = ['lib']
  s.files = [Dir.glob('lib/**/*'), 'README.md', 'LICENSE'].flatten
  s.required_ruby_version = '>= 2.0.0'
end
