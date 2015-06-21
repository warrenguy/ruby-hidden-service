Gem::Specification.new do |s|
  s.name        = 'ruby-hidden-service'
  s.version     = '0.0.1'
  s.licenses    = ['MIT']
  s.summary     = 'Automatically set up and tear down a Tor hidden service'
  s.description = 'Automatically set up and tear down a Tor hidden service'
  s.authors     = ['Warren Guy']
  s.email       = 'warren@guy.net.au'
  s.homepage    = 'https://github.com/warrenguy/ruby-hidden-service'

  s.files       = Dir['README.md', 'LICENSE', 'lib/**/*']

  s.add_dependency 'tor'
end
