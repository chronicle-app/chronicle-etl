
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "chronicle/etl/version"

Gem::Specification.new do |spec|
  spec.name          = "chronicle-etl"
  spec.version       = Chronicle::Etl::VERSION
  spec.authors       = ["Andrew Louis"]
  spec.email         = ["andrew@hyfen.net"]

  spec.summary       = "ETL tool for personal data"
  spec.description   = "Chronicle-ETL allows you to extract personal data from a variety of services, transformer it, and load it."
  spec.homepage      = "https://github.com/chronicle-app"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/chronicle-app/chronicle-etl"
    spec.metadata["changelog_uri"] = "https://github.com/chronicle-app/chronicle-etl"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 0.20"
  spec.add_dependency "colorize", "~> 0.8.1"
  spec.add_dependency "table_print"
  spec.add_dependency "ruby-progressbar", "~> 1.10"

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry-byebug", "~> 3.9"
end
