require_relative 'lib/hockey_gerrit/version'

Gem::Specification.new do |spec|
  spec.name          = 'hockey-gerrit'
  spec.version       = HockeyGerrit::VERSION
  spec.authors       = ['Trevor Renshaw', 'bootstraponline']
  spec.email         = %w[trenshaw@instructure.com code@bootstraponline.com]
  spec.summary       = 'Uploads a build from gerrit/Jenkins to hockeyapp'
  spec.description   = 'Uploads a build from gerrit/Jenkins to hockeyapp.'
  spec.license       = 'Apache-2.0'
  spec.homepage      = 'https://github.com/instructure/hockey-gerrit'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.bindir        = 'bin'

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_runtime_dependency 'faraday', '~> 0.9.2'
  spec.add_runtime_dependency 'faraday_middleware', '~> 0.10.0'

  spec.add_development_dependency 'safe_yaml', '~> 1.0', '>= 1.0.4'
  spec.add_development_dependency 'pry', '~> 0.10.3'
  spec.add_development_dependency 'trace_files', '~> 1.0'
  spec.add_development_dependency 'webmock', '~> 2.0', '>= 2.0.3'
  spec.add_development_dependency 'bundler', '~> 1.11', '>= 1.11.0'
  spec.add_development_dependency 'byebug', '~> 8.2.2', '>= 8.2.2'
  spec.add_development_dependency 'rake', '~> 11.1.1', '>= 11.1.1'
  spec.add_development_dependency 'rspec', '~> 3.4', '>= 3.4.0'
  spec.add_development_dependency 'rubocop', '~> 0.38', '>= 0.38'
  spec.add_development_dependency 'simplecov', '~> 0.11.2', '>= 0.11.2'
  spec.add_development_dependency 'coveralls', '~> 0.8.13', '>= 0.8.3'
end
