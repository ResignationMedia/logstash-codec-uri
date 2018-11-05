Gem::Specification.new do |s|
  s.name          = 'logstash-codec-uri'
  s.version       = '0.1.0'
  s.licenses      = ['Apache-2.0']
  s.summary       = 'URI encode / decode LogStash event data.'
  s.description   = 'Decodes URI encoded strings into complex data structures. Encodes complex data structures as a URI encoded string.'
  s.homepage      = 'https://github.com/ResignationMedia/logstash-codec-uri'
  s.authors       = ['Chris Brundage', 'Chive Media Group, LLC']
  s.email         = 'chris.brundage@chivemediagroup.com'
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "codec" }

  # Gem dependencies
  s.add_runtime_dependency 'logstash-core-plugin-api', "~> 2.0"
  s.add_runtime_dependency 'logstash-codec-line'
  s.add_development_dependency 'logstash-devutils'
end
